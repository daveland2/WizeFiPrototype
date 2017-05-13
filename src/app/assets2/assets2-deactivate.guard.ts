import { CanDeactivate } from '@angular/router';

import { Assets2Component } from './assets2.component';
import { IVerifyResult } from '../utilities/validity-check.class';

export class Assets2DeactivateGuard implements CanDeactivate<Assets2Component>
{
    canDeactivate(assets2Component: Assets2Component)
    {
        let result: IVerifyResult = assets2Component.gd.verifyAllDataValues();
        if (result.hadError)
        {
        	// report errors and remain on current screen
        	assets2Component.messages = result.messages;
        }
        else
        {
    	    // update application data model and proceed to next screen
    	    assets2Component.update();
    	}
        return !result.hadError;
    }

}   // class AssetsDeactivateGuard