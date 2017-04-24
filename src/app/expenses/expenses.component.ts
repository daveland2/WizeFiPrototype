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

	showAllTypes: boolean;
    showAllFields: boolean;

	areTypesVisible: any;
	areFieldsVisible: any;

	currentExpensesSubcategories: string[] = [];
	currentExpensesTypes: any = {};
	currentExpensesFields: any = {};

	selectedItem: string;
	selectedAction: string;

	subcatList: string[] = [];
	selectedSubcategory: string;

	typeList: string[] = [];
	selectedType: string;

	constructor(private ref: ApplicationRef, private dataModelService: DataModelService) { }

	ngOnInit()
	{
	    this.cExpenses = new CExpenses(this.dataModelService.getdata('expenses'));

		this.currentExpensesSubcategories = this.cExpenses.getSubcategories(this.cExpenses.expenses);
		this.currentExpensesTypes = this.cExpenses.getTypes(this.cExpenses.expenses);
		this.currentExpensesFields = this.cExpenses.getFields(this.cExpenses.expenses);

		let initialStatus = false;  // default initial status of visibility

		this.areTypesVisible = this.createAreTypesVisible(initialStatus);
		this.areFieldsVisible = this.createAreFieldsVisible(initialStatus);

		this.showAllTypes = initialStatus;
		this.showAllFields = initialStatus;

		this.selectedItem = 'Type';
		this.selectedAction = 'Add';

		this.updateItemManagement();

	}   // ngOnInit

    createAreTypesVisible(status:boolean): any
    {
    	let result = {};
        for (let subcat of Object.keys(this.cExpenses.expenses))
        {
            result[subcat] = status;
        }
    	return result;
    }   // createAreTypesVisible

	updateTypesVisibility()
	{
		for (let subcat of Object.keys(this.areTypesVisible))
		{
			this.areTypesVisible[subcat] = this.showAllTypes;
		}
	}   // updateTypesVisibility

	toggleTypeVisibility(subcat:string): void
	{
		this.areTypesVisible[subcat] = !this.areTypesVisible[subcat];
	}   // toggleTypeVisibility

    isTypeVisible(subcat:string): boolean
    {
    	return this.areTypesVisible[subcat];
    }   // isTypeVisible

    createAreFieldsVisible(status:boolean): any
    {
        let result = {};
        for (let subcat of Object.keys(this.cExpenses.expenses))
        {
            result[subcat] = {};
            for (let type of Object.keys(this.cExpenses.expenses[subcat]))
            {
                result[subcat][type] = status;
            }
        }
    	return result;
    }   // createAreFieldsVisible

    updateFieldsVisibility(): void
	{
		for (let subcat of Object.keys(this.areFieldsVisible))
		{
			for (let type of Object.keys(this.areFieldsVisible[subcat]))
			{
				this.areFieldsVisible[subcat][type] = this.showAllFields;
			}
		}
	}   // updateFieldsVisibility

	toggleFieldVisibility(subcat:string, type:string): void
	{
		this.areFieldsVisible[subcat][type] = !this.areFieldsVisible[subcat][type];
	}   // toggleFieldVisibility

    isFieldVisible(subcat:string, type:string): boolean
    {
    	return this.areFieldsVisible[subcat][type];
    }   // isFieldVisible

	dataType(val)
	{
		return (typeof val == 'number') ? 'number' : 'string';
	}

	updateItemManagement(): void
	{
		this.subcatList = this.cExpenses.getUpdateSubcategoryList(this.selectedItem, this.selectedAction);
		if (this.subcatList && this.subcatList.length > 0) this.selectedSubcategory =  this.subcatList[0];

		this.typeList = this.cExpenses.getUpdateTypeList(this.selectedItem, this.selectedAction, this.selectedSubcategory);
		if (this.typeList && this.typeList.length > 0) this.selectedType = this.typeList[0];
	}   // updateItemManagement

	onItemChange(): void
	{
		this.updateItemManagement();
	}   // onItemChange

	onActionChange(): void
	{
		this.updateItemManagement();
	}   // onActionChange

	onSubcategoryChange(): void
	{
		this.updateItemManagement();
	}   // onSubcategoryChange

	onTypeChange(): void
	{
		this.updateItemManagement();
	}   // onTypeChange

	verify(): void
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
	update(): void
	{
		this.dataModelService.putdata('expenses', this.cExpenses.expenses);
	}

}   // class ExpensesComponent
