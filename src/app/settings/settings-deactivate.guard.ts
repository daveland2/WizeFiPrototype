import { CanDeactivate } from '@angular/router';
import { SettingsComponent } from './settings.component';
import { IVerifyResult } from '../utilities/validity-check.class';


export class SettingsDeactivateGuard implements CanDeactivate<SettingsComponent> {

  canDeactivate(settingsComponent: SettingsComponent) {

    // process results
    let result: IVerifyResult = settingsComponent.cSettings.verifyAllDataValues();
    if (result.hadError) {
    	// report errors and remain on current screen
    	settingsComponent.messages = result.messages;
    }
    else {
	    // update application data model and proceed to next screen
	    settingsComponent.update();
	    console.log("memory resident data model has been updated");  //%//
	}

    return !result.hadError;
  }

}