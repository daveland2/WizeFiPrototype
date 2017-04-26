import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { GenericDataManagement } from '../utilities/generic-data-management.class';
import { ItemManagement } from '../utilities/item-management.class';
import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { CExpenses } from './expenses.class';
import { possibleExpenses } from './expenses.data';

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
    gd: GenericDataManagement;  // class to handle generic data presentation components in HTML
    im: ItemManagement; // // class to handle "Manage Items" feature

	constructor(private dataModelService: DataModelService) { }

	ngOnInit()
	{
	    this.cExpenses = new CExpenses(this.dataModelService.getdata('expenses'));
	    this.gd = new GenericDataManagement(this.cExpenses.expenses, possibleExpenses, this.messages);
	    this.im = new ItemManagement(this.gd, this.messages);
	}   // ngOnInit

    verify(): void
    /*
    This routine is triggered by a blur event on a numeric data field.
    */
    {
        this.messages = [];
        let result: IVerifyResult = this.gd.verifyAllDataValues();
        if (result.hadError)
        {
            // report errors on screen
            this.messages = result.messages;
        }
    }   //  verify

	// update application data model
	update(): void
	{
		this.dataModelService.putdata('expenses', this.cExpenses.expenses);
	}

}   // class ExpensesComponent
