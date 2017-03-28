export interface IBudgetDetails {
    housing: string;
    food: string;
}

export interface IVerifyResult {
	hadError: boolean,
	messages: string[]
}

export class CBudgetDetails {

    constructor (public budgetDetails: IBudgetDetails) { }

    getBudgetDetailsSum() {
        return Number(this.budgetDetails.housing) + Number(this.budgetDetails.food);
  	}   // getBudgetDetailsSum

  	checkInteger(item,result) {
  		let str = String(this.budgetDetails[item]);
  		if (!str.match(/^[0-9]+$/)) {
  			result.hadError = true;
  			result.messages.push('Must enter integer value for ' + item);
  		}
  	}   // checkInteger

  	verifyAllDataValues(): IVerifyResult {
  		// initialize
  		let result: IVerifyResult = {
  			hadError:false,
  			messages:[]
  		};

  		// check each data field
  		this.checkInteger('housing',result);
  		this.checkInteger('food',result);

  		return result;
  	}   // verifyAllDataValues
}   // class CBudgetDetails