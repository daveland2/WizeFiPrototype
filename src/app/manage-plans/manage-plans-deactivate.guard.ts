import { CanDeactivate } from '@angular/router';
import { ManagePlansComponent } from './manage-plans.component';
import { IVerifyResult } from '../utilities/validity-check.class';

export class ManagePlansDeactivateGuard implements CanDeactivate<ManagePlansComponent> {

  canDeactivate(managePlansComponent: ManagePlansComponent) {
	// update application data model and proceed to next screen
	managePlansComponent.update();
    return true;
  }

}