import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';

export interface IIncomeDetails {
    salary: number;
    interest: number;
}

export class CIncomeDetails {

    constructor (public incomeDetails: IIncomeDetails) { }

    getIncomeDetailsSum() {
        return Number(this.incomeDetails.salary) + Number(this.incomeDetails.interest);
  	}

  	verifyAllDataValues(): IVerifyResult {
  		// initialize
  		let result: IVerifyResult = {hadError:false, messages:[]};

  		// check each data field
  		CValidityCheck.checkInteger(this.incomeDetails,'salary',result);
  		CValidityCheck.checkInteger(this.incomeDetails,'interest',result);

  		return result;
  	}   // verifyAllDataValues

}