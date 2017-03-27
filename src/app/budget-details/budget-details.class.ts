export interface IBudgetDetails {
    housing: number;
    food: number;
}

export class CBudgetDetails {

    constructor (public budgetDetails: IBudgetDetails) { }

    getBudgetDetailsSum() {
    	// note kludge in use of *1 to convert string to number
        return this.budgetDetails.housing*1 + this.budgetDetails.food*1;
  	}
}