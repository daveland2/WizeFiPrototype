export interface IIncomeDetails {
    salary: string;
    interest: string;
}

export class CIncomeDetails {

    constructor (public incomeDetails: IIncomeDetails) { }

    getIncomeDetailsSum() {
        return Number(this.incomeDetails.salary) + Number(this.incomeDetails.interest);
  	}
}