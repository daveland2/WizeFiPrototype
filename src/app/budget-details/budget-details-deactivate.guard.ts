import { CanDeactivate } from '@angular/router';
import { BudgetDetailsComponent } from './budget-details.component';
import { IVerifyResult } from '../utilities/validity-check.class';


export class BudgetDetailsDeactivateGuard implements CanDeactivate<BudgetDetailsComponent> {

  canDeactivate(budgetDetailsComponent: BudgetDetailsComponent) {
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