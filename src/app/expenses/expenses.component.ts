import { Component, OnInit } from '@angular/core';
import { ApplicationRef } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { IVerifyResult } from '../utilities/validity-check.class';
import { CExpenses } from './expenses.class';

@Component({
  selector: 'app-expenses',
  templateUrl: './expenses.component.html',
  styleUrls: ['./expenses.component.css']
})
export class ExpensesComponent implements OnInit
{
	// persistent data
    cExpenses: CExpenses;

    // transient data
    messages: string[] = [];
	currentExpensesSubcategories: string[] = [];
	currentExpensesTypes: any = {};

	selectedItem: string;
	selectedAction: string;
	selectedSubcategory: string;
	selectedType: string;

	constructor(private ref: ApplicationRef, private dataModelService: DataModelService) { }

	ngOnInit()
	{
	    this.cExpenses = new CExpenses(this.dataModelService.getdata('expenses'));

		this.currentExpensesSubcategories = this.cExpenses.getExpenseSubcategories(this.cExpenses.expenses);
		this.currentExpensesTypes = this.cExpenses.getExpenseTypes(this.cExpenses.expenses);

		this.selectedItem = 'Type';
		this.selectedAction = 'Add';
		this.selectedSubcategory = '';
		this.selectedType = '';

	}   // ngOnInit

	onItemChange()
	{

	}   // onItemChange

	onActionChange()
	{

	}   // onActionChange

	onSubcategoryChange()
	{

	}   // onSubcategoryChange

	onTypeChange()
	{

	}   // onTypeChange

	verify()
	{
		this.messages = [];
		let result: IVerifyResult = this.cExpenses.verifyAllDataValues();
		if (result.hadError) {
			// report errors on screen
			this.messages = result.messages;
			this.ref.tick();  // force change detection so screen will be updated
		}
	} //  verify

	// update data model
	update()
	{
		this.dataModelService.putdata('expenses', this.cExpenses.expenses);
	}

}   // class ExpensesComponent
