import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';

export interface IBudgetDetails {
    housing: string;
    food: string;
}

export class CBudgetDetails {

    constructor (public budgetDetails: IBudgetDetails) { }

    getBudgetDetailsSum() {
        return Number(this.budgetDetails.housing) + Number(this.budgetDetails.food);
  	}   // getBudgetDetailsSum

  	verifyAllDataValues(): IVerifyResult {
  		// initialize
  		let result: IVerifyResult = {hadError:false, messages:[]};

  		// check each data field
  		CValidityCheck.checkInteger(this.budgetDetails,'housing',result);
  		CValidityCheck.checkInteger(this.budgetDetails,'food',result);

  		return result;
  	}   // verifyAllDataValues

}   // class CBudgetDetails