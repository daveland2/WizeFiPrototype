import { Injectable } from '@angular/core';

import { IProfile } from './profile/profile.class';
import { IBudgetDetails } from './budget-details/budget-details.class';
import { IIncomeDetails } from './income-details/income-details.class';

export interface IGlobal {
	userID: string,
	email: string,
	access_token: string,
	lambda: any,
}

export interface ISettings {
	currencyCode: string,
	thousandsSeparator: string,
	decimalSeparator: string
}

export interface IDataModel {
	global: IGlobal,
	persistent: {
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
				userID: '123',
				email: 'joe@abc.com',
				access_token: '12345',
				lambda: null
    		},
    		persistent: {
				settings: {
					currencyCode: 'EUR',
					thousandsSeparator: '',
					decimalSeparator: ''
	    		},
				profile: {
					name: "Joe",
					age: 25
				},
				budgetDetails: {
					housing: 500,
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
	    let email,payload,params;

	    // initialize
	    email = this.dataModel.global.email;

	    // set params to guide function invocation
	    if (mode == "get") payload = {mode:"get", email:email};
	    else payload = {mode:"put", email:email, info:JSON.stringify(this.dataModel.persistent)};
	    params =
	    {
	        FunctionName: 'processData',
	        Payload: JSON.stringify(payload)
	    };

	    // invoke Lambda function to process data
	    this.dataModel.global.lambda.invoke(params, (err,data) =>
	    {
	        if (err)
	        {
	            console.log(err);
	        }
	        else
	        {
	            if (!data.hasOwnProperty('Payload'))
	            {
	                console.log("Data does not contain Payload attribute");
	            }
	            else
	            {
	                payload = JSON.parse(data.Payload);
	                console.log("Payload = " + data.Payload);
	                if (mode == "get")
	                {
	                    if (payload.hasOwnProperty('errorMessage'))
	                    {
	                        console.log("errorMessage: " + payload.errorMessage);
	                    }
	                    else
	                    {
	                        this.dataModel.persistent = JSON.parse(payload);
	                        console.log("persistent data has been retrieved");
	                    }
	                }
	                else
	                {
                        console.log("persistent data has been stored");
	                }
	            }
	        }
	    });
	}   // invokeDataHandlingFunction

	fetchdata(): IDataModel {
		// simulate fetch of data from persistent storage
		this.invokeDataHandlingFunction('get');
		console.log("fetch: " + JSON.stringify(this.dataModel.persistent));  //*//
		return this.dataModel;
	}   // fetchdata

	storedata() {
		// simulate store of data to persistent storage
		this.invokeDataHandlingFunction('put');
		console.log("store: " + JSON.stringify(this.dataModel.persistent));  //*//
	}   // storedata

	getdata(item) {
		let value: any;
		switch (item)
		{
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
			case 'profile':        this.dataModel.persistent.profile = JSON.parse(JSON.stringify(value));        break;
			case 'budgetDetails':  this.dataModel.persistent.budgetDetails = JSON.parse(JSON.stringify(value));  break;
			case 'incomeDetails':  this.dataModel.persistent.incomeDetails = JSON.parse(JSON.stringify(value));  break;
			default:
			    console.log(item + ' not found in putdata in DataModelService');
		}
	}   // putdata

}   // class DataModelService
