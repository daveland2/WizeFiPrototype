import { CanDeactivate } from '@angular/router';
import { AssetsComponent } from './assets.component';
import { IVerifyResult } from '../utilities/validity-check.class';

export class AssetsDeactivateGuard implements CanDeactivate<AssetsComponent> {

  canDeactivate(assetsComponent: AssetsComponent) {

    // initialize
    console.log('canDeactivate called for AssetsComponent');  //%//

    // process results
    let result: IVerifyResult = assetsComponent.cAssets.verifyAllDataValues();
    if (result.hadError) {
    	// report errors and remain on current screen
    	assetsComponent.messages = result.messages;
    }
    else {
	    // update application data model and proceed to next screen
	    assetsComponent.update();
	    console.log("memory resident data model has been updated");  //%//
	}

    return !result.hadError;
  }

}