import { Injectable } from '@angular/core';

export interface Ibudgetdetails {
	housing: number,
	food: number
}

export interface Iincomedetails {
	salary: number,
	interest: number
}

export interface Idatamodel {
	budgetdetails: Ibudgetdetails,
	incomedetails: Iincomedetails
}

@Injectable()
export class DataModelService {
    datamodel: Idatamodel;

	fetchdata(): Idatamodel {
		// simulate fetch of data from persistent storage
		this.datamodel = {
			budgetdetails: {
				housing: 500,
				food: 250
			},
			incomedetails: {
				salary: 3000,
				interest: 400
			}
		}
		console.log("fetch: " + JSON.stringify(this.datamodel));  //*//
		return this.datamodel;
	}   // fetchdata

	storedata() {
		console.log("store: " + JSON.stringify(this.datamodel));  //*//
	}   // storedata

	getdata(item) {
		let value: any;
		switch (item)
		{
			case 'budgetdetails':  value = JSON.parse(JSON.stringify(this.datamodel.budgetdetails));  break;
			case 'incomedetails':  value = JSON.parse(JSON.stringify(this.datamodel.incomedetails));  break;
			default:               value = null;  // need error message here
		}
		return value;
	}   // getdata

	putdata(item,value) {
		switch (item)
		{
			case 'budgetdetails':  this.datamodel.budgetdetails = JSON.parse(JSON.stringify(value));  break;
			case 'incomedetails':  this.datamodel.incomedetails = JSON.parse(JSON.stringify(value));  break;
			default:  ;  // need error message here
		}
	}   // putdata

    // note: use class instead of interface for budgetdetails, and make this a member function of that class?
	getBudgetDetailsSum(budgetdetails) {
		if (!budgetdetails) budgetdetails = this.datamodel.budgetdetails;
        // note kludge of *1 to convert string to number (otherwise + is string concatenation)
        return budgetdetails.housing*1 + budgetdetails.food*1;
  	}   // getBudgetDetailsSum

  	getIncomeDetailsSum(incomedetails) {
        // note kludge of *1 to convert string to number (otherwise + is string concatenation)
        return incomedetails.salary*1 + incomedetails.interest*1;
  	}   // getIncomeDetailsSum


}   // class DataModelService
