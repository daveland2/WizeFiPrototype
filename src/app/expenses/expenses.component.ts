import { Component, OnInit } from '@angular/core';
import { ApplicationRef } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { CExpenses } from './expenses.class';
import { possibleExpenses } from './expenses.data'

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
    wantHiddenFields: boolean;

	areTypesVisible: any;
	areFieldsVisible: any;

	currentExpensesSubcategories: string[] = [];
	currentExpensesTypes: any = {};
	currentExpensesFields: any = {};

	selectedItem: string;
	selectedAction: string;

	subcatList: string[] = [];
	selectedSubcategory: string;
	customSubcategory: string = '';

	typeList: string[] = [];
	selectedType: string;
	customType: string = '';

	fieldList: string[] = [];
	selectedField: string;
	customField: string = '';

	constructor(private ref: ApplicationRef, private dataModelService: DataModelService) { }

	ngOnInit()
	{
	    this.cExpenses = new CExpenses(this.dataModelService.getdata('expenses'));

		this.currentExpensesSubcategories = this.cExpenses.getSubcategories(this.cExpenses.expenses);
		this.currentExpensesTypes = this.cExpenses.getTypes(this.cExpenses.expenses);
		this.currentExpensesFields = this.cExpenses.getFields(this.cExpenses.expenses, this.wantHiddenFields);

		let initialStatus = false;  // default initial status of visibility

		this.areTypesVisible = this.createAreTypesVisible(initialStatus);
		this.areFieldsVisible = this.createAreFieldsVisible(initialStatus);

		this.showAllTypes = initialStatus;
		this.showAllFields = initialStatus;
		this.wantHiddenFields = false;

		this.selectedItem = 'Subcategory';
		this.selectedAction = 'Add';

		// update subcategories list
		this.subcatList = this.cExpenses.getUpdateSubcategoryList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction);
		if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];

		// update type list
		this.typeList = this.cExpenses.getUpdateTypeList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory);
		if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];

		// update field list
		this.fieldList = this.cExpenses.getUpdateFieldList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType, this.wantHiddenFields);
		if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
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

    updateHiddenFieldsVisibility()
    {
    	this.currentExpensesFields = this.cExpenses.getFields(this.cExpenses.expenses, this.wantHiddenFields);
    }   // updateHiddenFieldsVisibility

	dataType(val)
	{
		let result = (typeof val == 'number' || (typeof val == 'string' && !isNaN(+val))) ? 'number' : 'string';  //%//
		return (typeof val == 'number' || (typeof val == 'string' && !isNaN(+val))) ? 'number' : 'string';
	}   // dataType

	onItemChange(): void
	{
		// update subcategories list
		this.subcatList = this.cExpenses.getUpdateSubcategoryList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction);
		if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];
		this.customSubcategory = '';

		// update type list
		this.typeList = this.cExpenses.getUpdateTypeList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory);
		if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];
		this.customType = '';

		// update field list
		this.fieldList = this.cExpenses.getUpdateFieldList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType, this.wantHiddenFields);
		if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
		this.customField = '';
	}   // onItemChange

	onActionChange(): void
	{
		// update subcategories list
		this.subcatList = this.cExpenses.getUpdateSubcategoryList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction);
		if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];
		this.customSubcategory = '';

		// update type list
		this.typeList = this.cExpenses.getUpdateTypeList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory);
		if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];
		this.customType = '';

		// update field list
		this.fieldList = this.cExpenses.getUpdateFieldList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType, this.wantHiddenFields);
		if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
		this.customField = '';
	}   // onActionChange

	onSubcategoryChange(): void
	{
		// update type list
		this.typeList = this.cExpenses.getUpdateTypeList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory);
		if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];

		// update field list
		this.fieldList = this.cExpenses.getUpdateFieldList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType, this.wantHiddenFields);
		if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
	}   // onSubcategoryChange

	onTypeChange(): void
	{
		// update field list
		this.fieldList = this.cExpenses.getUpdateFieldList(this.cExpenses.expenses, possibleExpenses, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType, this.wantHiddenFields);
		if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
	}   // onTypeChange

	onFieldChange(): void
	{
		// no action required
	}   // onFieldChange

	performAction(): void
	/*
	This routine performs the specified action requested in the "Manage Items" section
	*/
	{
		console.log("performAction");
		let wantRefresh: boolean = true;
		let hadError: boolean = false;
		let item: string = this.selectedItem;
		let action: string = this.selectedAction;
       	let subcat: string = this.selectedSubcategory;
       	let type: string = this.selectedType;
       	let field: string = this.selectedField;

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
        		if (subcat == 'custom') subcat = this.customSubcategory
				if (type == 'custom') type = this.customType;
				if (field == 'custom') field = this.customField;

				if (CValidityCheck.checkAttributeNameValidity('subcat', subcat, this.messages)) hadError = true;
				if (CValidityCheck.checkAttributeNameValidity('type', type, this.messages)) hadError = true;
				if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;

        		if (!hadError)
        		{
					this.cExpenses.expenses[subcat] = {};
					this.cExpenses.expenses[subcat]['label'] = subcat;
					this.cExpenses.expenses[subcat][type] = {};
					this.cExpenses.expenses[subcat][type]['label'] = type;
					this.cExpenses.expenses[subcat][type]['monthlyAmount'] = 0;
					if (field != 'none') this.cExpenses.expenses[subcat][type][field] = '';
        		}
            }

            if (action == 'Delete')
            {
            	if (!confirm('Do you intend to delete the subcategory: ' + subcat))
            	{
            		wantRefresh = false;
            	}
            	else
            	{
            		delete this.cExpenses.expenses[subcat];
            	}

            }
        }   // Subcategory

        if (item == 'Type')
        {
            if (action == 'Add')
            {
        		if (type == 'custom') type = this.customType;
            	if (field == 'custom') field = this.customField;

				if (CValidityCheck.checkAttributeNameValidity('type', type, this.messages)) hadError = true;
				if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;

				if (!hadError)
        		{
					this.cExpenses.expenses[subcat][type] = {};
					this.cExpenses.expenses[subcat][type]['label'] = type;
					this.cExpenses.expenses[subcat][type]['monthlyAmount'] = 0;
					if (field != 'none') this.cExpenses.expenses[subcat][type][field] = '';
        		}
            }

            if (action == 'Delete')
            {
            	if (!confirm('Do you intend to delete the type: '+subcat+'.'+type))
            	{
            		wantRefresh = false;
            	}
            	else
            	{
            		delete this.cExpenses.expenses[subcat][type];
            	}
            }
        }   // Type

        if (item == 'Field')
        {
            if (action == 'Add')
            {
            	if (field == 'none')
            	{
            		wantRefresh = false;
            	}
            	else
            	{
            		if (field == 'custom') field = this.customField;
					if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;

					if (!hadError)
            		{
						this.cExpenses.expenses[subcat][type][field] = '';
            		}
				}
            }

            if (action == 'Delete')
            {
            	if (!confirm('Do you intend to delete the field: '+subcat+'.'+type+'.'+field))
            	{
            		wantRefresh = false;
            	}
            	else
            	{
            		delete this.cExpenses.expenses[subcat][type][field];
            	}
            }
        }   // Field

	    // update screen
	    if (wantRefresh && !hadError)
	    {
	    	this.areTypesVisible = this.createAreTypesVisible(this.showAllTypes);
			this.areFieldsVisible = this.createAreFieldsVisible(this.showAllFields);
			this.currentExpensesSubcategories = this.cExpenses.getSubcategories(this.cExpenses.expenses);
			this.currentExpensesTypes = this.cExpenses.getTypes(this.cExpenses.expenses);
			this.currentExpensesFields = this.cExpenses.getFields(this.cExpenses.expenses, this.wantHiddenFields);
		}
	}   // performAction

	verify(): void
	{
		this.messages = [];
		let result: IVerifyResult = this.cExpenses.verifyAllDataValues(this.cExpenses.expenses);
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