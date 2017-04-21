import { Injectable } from '@angular/core';

import { ISettings } from '../settings/settings.class';
import { IProfile } from '../profile/profile.class';
import { IBudgetDetails } from '../budget-details/budget-details.class';
import { IIncomeDetails } from '../income-details/income-details.class';
import { IAssets } from '../assets/assets.class';
import { dataModel } from './data-model_1.data'

export interface IGlobal
{
	isLoggedIn: boolean,
	isNewUser: boolean,
	userID: string,
	email: string,
	access_token: string,
	lambda: any
}

export interface IHeader
{
	dataVersion: number,
	dateCreated: string,
	dateUpdated: string,   // note: date string is in ISO-8601 format: YYYY-MM-DDTHH:mm:ss.sssZ
	stripeCustomerID: string,
	stripeSubscriptionID: string,
	curplan: string
}

export interface IPlan
{
	budgetDetails: IBudgetDetails,
	incomeDetails: IIncomeDetails,
	assets: IAssets
}

export interface IDataModel
{
	global: IGlobal,
	persistent: {
		header: IHeader,
		settings: ISettings,
		profile: IProfile,
		plans: {
			original: IPlan,
			current: IPlan
	    }
    }
}

@Injectable()
export class DataModelService
{
    dataModel: IDataModel;

    constructor ()
    {
    	// set data model to initial default configuration
    	this.dataModel = dataModel;
    }   // constructor

	invokeDataHandlingFunction(mode)
	{
		return new Promise((resolve,reject) =>
	    {
		    let email,payload,params;

		    // initialize
		    email = this.dataModel.global.email;

		    // set params to guide function invocation
		    if (mode == "get") payload = {mode:"get", email:email};
		    else payload = {mode:"put", email:email, persistent:JSON.stringify(this.dataModel.persistent)};
		    params =
		    {
		        FunctionName: 'processWizeFiPrototype',
		        Payload: JSON.stringify(payload)
		    };

		    // invoke Lambda function to process data
		    this.dataModel.global.lambda.invoke(params, (err,data) =>
		    {
		        if (err)
		        {
		            console.log(err);  //%//
		        	reject(err);
		        }
		        else
		        {
		            if (!data.hasOwnProperty('Payload'))
		            {
		                console.log("Data does not contain Payload attribute");  //%//
		                reject("Data does not contain Payload attribute");
		            }
		            else
		            {
		                payload = JSON.parse(data.Payload);
		                if (mode == "put")
		                {
	                        console.log("persistent data has been stored");  //%//
	                        resolve();
		                }
		                else
		                {
		                    if (payload.hasOwnProperty('errorMessage'))
		                    {
		                    	if (payload.errorMessage == "NEWUSER")
		                    	{
		                    		this.dataModel.global.isNewUser = true;
		                    		this.dataModel.persistent.header.dateCreated = (new Date()).toISOString();
		                    		this.dataModel.persistent.header.dateUpdated = this.dataModel.persistent.header.dateCreated;
		                    		resolve();
		                    	}
		                    	else
		                    	{
			                        reject("errorMessage: " + payload.errorMessage);
		                    	}
		                    }
		                    else
		                    {
	                    		this.dataModel.global.isNewUser = false;
		                        this.dataModel.persistent = JSON.parse(payload);
		                        console.log("persistent data has been retrieved");  //%//
		                        resolve();
		                    }
		                }
		            }
		        }
		    }); // lambda invoke
		});   // return new Promise
	}   // invokeDataHandlingFunction

	fetchdata()
	{
		// fetch data from persistent storage
		return new Promise((resolve,reject) =>
	    {
	    	let finishFetch = ():void =>
	    	{
				console.log("fetch: " + JSON.stringify(this.dataModel.persistent));  //%//
				resolve();
			}

			let handleError = (err:any):void =>
			{
			    reject(err);
			}

			this.invokeDataHandlingFunction('get')
			.then(finishFetch)
			.catch(handleError);
		}); // return new Promise
	}   // fetchdata

	storedata()
	{
		// store data in persistent storage
		return new Promise((resolve,reject) =>
	    {
	    	let finishStore = ():void =>
	    	{
				console.log("store: " + JSON.stringify(this.dataModel.persistent));  //%//
				resolve();
			}

			let handleError = (err: any):void =>
			{
			    console.log(err);  //%//
			    reject(err);
			}

			dataModel.persistent.header.dateUpdated = (new Date()).toISOString();
			this.invokeDataHandlingFunction('put')
			.then(finishStore)
			.catch(handleError);
		}); // return new Promise
	}   // storedata

	getdata(item)
	{
		let value: any;
		let plan = this.dataModel.persistent.header.curplan;

		switch (item)
		{
			case 'settings':       value = JSON.parse(JSON.stringify(this.dataModel.persistent.settings));                   break;
			case 'profile':        value = JSON.parse(JSON.stringify(this.dataModel.persistent.profile));                    break;
			case 'budgetDetails':  value = JSON.parse(JSON.stringify(this.dataModel.persistent.plans[plan].budgetDetails));  break;
			case 'incomeDetails':  value = JSON.parse(JSON.stringify(this.dataModel.persistent.plans[plan].incomeDetails));  break;
			case 'assets':         value = JSON.parse(JSON.stringify(this.dataModel.persistent.plans[plan].assets));         break;
			default:
			    value = null;
			    console.log(item + ' not found in getdata in DataModelService');
		}
		return value;
	}   // getdata

	putdata(item,value)
	{
		let plan = this.dataModel.persistent.header.curplan;

		switch (item)
		{
			case 'settings':       this.dataModel.persistent.settings                  = JSON.parse(JSON.stringify(value));  break;
			case 'profile':        this.dataModel.persistent.profile                   = JSON.parse(JSON.stringify(value));  break;
			case 'budgetDetails':  this.dataModel.persistent.plans[plan].budgetDetails = JSON.parse(JSON.stringify(value));  break;
			case 'incomeDetails':  this.dataModel.persistent.plans[plan].incomeDetails = JSON.parse(JSON.stringify(value));  break;
			case 'assets':         this.dataModel.persistent.plans[plan].assets        = JSON.parse(JSON.stringify(value));  break;
			default:
			    console.log(item + ' not found in putdata in DataModelService');
		}
	}   // putdata

}   // class DataModelService
