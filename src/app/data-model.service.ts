import { Injectable } from '@angular/core';

import { IBudgetDetails } from './budget-details/budget-details.class';
import { IIncomeDetails } from './income-details/income-details.class';

export interface IDataModel {
	budgetDetails: IBudgetDetails,
	incomeDetails: IIncomeDetails
}

@Injectable()
export class DataModelService {
    dataModel: IDataModel;

	fetchdata(): IDataModel {
		// simulate fetch of data from persistent storage
		this.dataModel = {
			budgetDetails: {
				housing: 500,
				food: 250
			},
			incomeDetails: {
				salary: 3000,
				interest: 400
			}
		}
		console.log("fetch: " + JSON.stringify(this.dataModel));  //*//
		return this.dataModel;
	}   // fetchdata

	storedata() {
		console.log("store: " + JSON.stringify(this.dataModel));  //*//
	}   // storedata

	getdata(item) {
		let value: any;
		switch (item)
		{
			case 'budgetDetails':  value = JSON.parse(JSON.stringify(this.dataModel.budgetDetails));  break;
			case 'incomeDetails':  value = JSON.parse(JSON.stringify(this.dataModel.incomeDetails));  break;
			default:
			    value = null;
			    console.log(item + ' not found in getdata in DataModelService');
		}
		return value;
	}   // getdata

	putdata(item,value) {
		switch (item)
		{
			case 'budgetDetails':  this.dataModel.budgetDetails = JSON.parse(JSON.stringify(value));  break;
			case 'incomeDetails':  this.dataModel.incomeDetails = JSON.parse(JSON.stringify(value));  break;
			default:  console.log(item + ' not found in putdata in DataModelService');
		}
	}   // putdata

}   // class DataModelService
