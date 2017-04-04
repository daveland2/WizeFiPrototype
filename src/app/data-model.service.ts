import { Injectable } from '@angular/core';

import { IProfile } from './profile/profile.class';
import { IBudgetDetails } from './budget-details/budget-details.class';
import { IIncomeDetails } from './income-details/income-details.class';

export interface IConfig {
	userID: string,
	email: string,
	access_token: string,
	lambda: any,
	thousandsSeparator: string,
	decimalSeparator: string
}

export interface IDataModel {
	config: IConfig,
	persistent: {
		profile: IProfile,
		budgetDetails: IBudgetDetails,
		incomeDetails: IIncomeDetails
    }
}

@Injectable()
export class DataModelService {
    dataModel: IDataModel;

    constructor () {
    	// set data model to initial configuration
    	this.dataModel = {
			config: {
				userID: '123',
				email: 'joe@abc.com',
				access_token: '12345',
				lambda: null,
				thousandsSeparator: '',
				decimalSeparator: ''
    		},
    		persistent: {
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
				}    		}
    	};
    }   // constructor

	fetchdata(): IDataModel {
		// simulate fetch of data from persistent storage
		this.dataModel.persistent = {
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
		console.log("fetch: " + JSON.stringify(this.dataModel.persistent));  //*//
		return this.dataModel;
	}   // fetchdata

	storedata() {
		// simulate store of data to persistent storage
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
