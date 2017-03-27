export interface IIncomeDetails {
    salary: number;
    interest: number;
}

export class CIncomeDetails {

    constructor (public incomeDetails: IIncomeDetails) { }

    getIncomeDetailsSum() {
    	// note kludge in use of *1 to convert string to number
        return this.incomeDetails.salary*1 + this.incomeDetails.interest*1;
  	}
}