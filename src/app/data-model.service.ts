import { Injectable } from '@angular/core';

import { ISettings } from './settings/settings.class';
import { IProfile } from './profile/profile.class';
import { IBudgetDetails } from './budget-details/budget-details.class';
import { IIncomeDetails } from './income-details/income-details.class';

export interface IGlobal {
	isNewUser: boolean,
	userID: string,
	email: string,
	access_token: string,
	lambda: any,
}

export interface IHeader {
	dataVersion: number,
	dateCreated: string,
	dateUpdated: string
	// note: date string is in ISO-8601 format: YYYY-MM-DDTHH:mm:ss.sssZ
}

export interface IDataModel {
	global: IGlobal,
	persistent: {
		header: IHeader,
		settings: ISettings,
		profile: IProfile,
		budgetDetails: IBudgetDetails,
		incomeDetails: IIncomeDetails
    }
}

@Injectable()
export class DataModelService {
    dataModel: IDataModel;

    constructor () {
    	// set data model to initial default configuration
    	this.dataModel = {
			global: {
				isNewUser: true,
				userID: '123',
				email: 'joe@abc.com',
				access_token: '12345',
				lambda: null
    		},
    		persistent: {
    			header: {
    				dataVersion: 1,
    				dateCreated: '2017-04-05T12:14:32.456Z',
    				dateUpdated: '2017-04-05T12:15:32.456Z'
    			},
				settings: {
					currencyCode: '',
					thousandsSeparator: '',
					decimalSeparator: ''
	    		},
				profile: {
					name: '',
					age: null
				},
				budgetDetails: {
					housing: null,
					food: 250
				},
				incomeDetails: {
					salary: 3000,
					interest: 400
				}
			}
    	};
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
		        	reject(err);
		            console.log(err);
		        }
		        else
		        {
		            if (!data.hasOwnProperty('Payload'))
		            {
		                console.log("Data does not contain Payload attribute");
		                reject("Data does not contain Payload attribute");
		            }
		            else
		            {
		                payload = JSON.parse(data.Payload);
		                if (mode == "get")
		                {
		                    if (payload.hasOwnProperty('errorMessage'))
		                    {
		                    	if (payload.errorMessage == "NEWUSER")
		                    	{
		                    		this.dataModel.global.isNewUser = true;
		                    		this.dataModel.persistent.header.dateCreated = (new Date()).toISOString();
		                    		resolve();
		                    	}
		                    	else
		                    	{
			                        console.log("errorMessage: " + payload.errorMessage);
			                        reject("errorMessage: " + payload.errorMessage);
		                    	}
		                    }
		                    else
		                    {
	                    		this.dataModel.global.isNewUser = false;
		                        this.dataModel.persistent = JSON.parse(payload);
		                        console.log("persistent data has been retrieved");
		                        resolve();
		                    }
		                }
		                else
		                {
	                        console.log("persistent data has been stored");
	                        resolve();
		                }
		            }
		        }
		    }); // lambda invoke
		});   // return new Promise
	}   // invokeDataHandlingFunction

	fetchdata() {
		// kludge to get information into scope of nested function
		let dataModel = this.dataModel;

		// fetch data from persistent storage
		return new Promise((resolve,reject) =>
	    {
	    	function finishFetch()
	    	{
				console.log("fetch: " + JSON.stringify(dataModel.persistent));  //%//
				resolve();
			}

			function handleError(err)
			{
			    console.log(err);
			    reject(err);
			}

			this.invokeDataHandlingFunction('get')
			.then(finishFetch)
			.catch(handleError);
		}); // return new Promise
	}   // fetchdata

	storedata() {
		// kludge to get information into scope of nested function
		let dataModel = this.dataModel;

		// store data in persistent storage
		return new Promise((resolve,reject) =>
	    {
	    	function finishStore()
	    	{
				console.log("store: " + JSON.stringify(dataModel.persistent));  //%//
				resolve();
			}

			function handleError(err)
			{
			    console.log(err);
			    reject(err);
			}

			dataModel.persistent.header.dateUpdated = (new Date()).toISOString();
			this.invokeDataHandlingFunction('put')
			.then(finishStore)
			.catch(handleError);
		}); // return new Promise
	}   // storedata

	getdata(item) {
		let value: any;
		switch (item)
		{
			case 'settings':       value = JSON.parse(JSON.stringify(this.dataModel.persistent.settings));       break;
			case 'profile':        value = JSON.parse(JSON.stringify(this.dataModel.persistent.profile));        break;
			case 'budgetDetails':  value = JSON.parse(JSON.stringify(this.dataModel.persistent.budgetDetails));  break;
			case 'incomeDetails':  value = JSON.parse(JSON.stringify(this.dataModel.persistent.incomeDetails));  break;
			default:
			    value = null;
			    console.log(item + ' not found in getdata in DataModelService');
		}
		return value;
	}   // getdata

	putdata(item,value) {
		switch (item)
		{
			case 'settings':       this.dataModel.persistent.settings      = JSON.parse(JSON.stringify(value));  break;
			case 'profile':        this.dataModel.persistent.profile       = JSON.parse(JSON.stringify(value));  break;
			case 'budgetDetails':  this.dataModel.persistent.budgetDetails = JSON.parse(JSON.stringify(value));  break;
			case 'incomeDetails':  this.dataModel.persistent.incomeDetails = JSON.parse(JSON.stringify(value));  break;
			default:
			    console.log(item + ' not found in putdata in DataModelService');
		}
	}   // putdata

}   // class DataModelService
