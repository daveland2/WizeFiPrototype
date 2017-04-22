import { CanDeactivate } from '@angular/router';
import { IncomeDetailsComponent } from './income-details.component';
import { IVerifyResult } from '../utilities/validity-check.class';


export class IncomeDetailsDeactivateGuard implements CanDeactivate<IncomeDetailsComponent> {

  canDeactivate(incomeDetailsComponent: IncomeDetailsComponent) {
    let result: IVerifyResult = incomeDetailsComponent.cIncomeDetails.verifyAllDataValues();
    if (result.hadError) {
    	// report errors and remain on current screen
    	incomeDetailsComponent.messages = result.messages;
    }
    else {
	    // update application data model and proceed to next screen
	    incomeDetailsComponent.update();
	}

    return !result.hadError;
  }

}