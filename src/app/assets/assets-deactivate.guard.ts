import { CanDeactivate } from '@angular/router';
import { AssetsComponent } from './assets.component';
import { IVerifyResult } from '../utilities/validity-check.class';

export class AssetsDeactivateGuard implements CanDeactivate<AssetsComponent>
{
    canDeactivate(assetsComponent: AssetsComponent)
    {
        let result: IVerifyResult = assetsComponent.cAssets.verifyAllDataValues();
        if (result.hadError)
        {
        	// report errors and remain on current screen
        	assetsComponent.messages = result.messages;
        }
        else
        {
    	    // update application data model and proceed to next screen
    	    assetsComponent.update();
    	}
        return !result.hadError;
    }

}   // class AssetsDeactivateGuard