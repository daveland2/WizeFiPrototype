import { CanDeactivate } from '@angular/router';
import { BudgetDetailsComponent } from './budget-details.component';
import { IVerifyResult } from './budget-details.class';

export class BudgetDetailsDeactivateGuard implements CanDeactivate<BudgetDetailsComponent> {

  canDeactivate(budgetDetailsComponent: BudgetDetailsComponent) {

    // initialize
    console.log('canDeactivate called for BudgetDetailsComponent');  //%//

    // process results
    let result: IVerifyResult = budgetDetailsComponent.cBudgetDetails.verifyAllDataValues();
    if (result.hadError) {
    	// report errors and remain on current screen
    	budgetDetailsComponent.messages = result.messages;
    }
    else {
	    // update application data model and proceed to next screen
	    budgetDetailsComponent.update();
	    console.log("memory resident data model has been updated");  //%//
	}

    return !result.hadError;
  }

}