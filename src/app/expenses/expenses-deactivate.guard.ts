import { CanDeactivate } from '@angular/router';
import { ExpensesComponent } from './expenses.component';
import { GD } from '../utilities/gd.class';

import { IVerifyResult } from '../utilities/validity-check.class';

export class ExpensesDeactivateGuard implements CanDeactivate<ExpensesComponent> {

  canDeactivate(expensesComponent: ExpensesComponent) {
    let result: IVerifyResult = GD.verifyAllDataValues(expensesComponent.cExpenses.expenses);
    if (result.hadError) {
    	// report errors and remain on current screen
    	expensesComponent.messages = result.messages;
    }
    else {
	    // update application data model and proceed to next screen
	    expensesComponent.update();
	  }
    return !result.hadError;
  }

}