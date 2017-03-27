export class BudgetDetails {

    constructor (public housing:number, public food:number) { }

    getBudgetDetailsSum() {
        return this.housing + this.food;
  	}
}