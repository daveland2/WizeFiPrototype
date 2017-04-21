import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';

export interface IAssets {
}

export class CAssets {

    constructor (public assets: IAssets) { }

    getAssetsSum() {
        return 0;  //%//
  	}   // getAssetsSum

  	verifyAllDataValues(): IVerifyResult {
  		// initialize
  		let result: IVerifyResult = {hadError:false, messages:[]};

      /*
  		// check each data field
  		CValidityCheck.checkInteger(this.assets,'housing',result);
  		CValidityCheck.checkInteger(this.assets,'food',result);
      */

  		return result;
  	}   // verifyAllDataValues

}   // class CAssets