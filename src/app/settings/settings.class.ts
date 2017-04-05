import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';

export interface ISettings {
  currencyCode: string,
  thousandsSeparator: string,
  decimalSeparator: string
}

export class CSettings {

    constructor (public settings: ISettings) { }

    verifyAllDataValues(): IVerifyResult {
      // initialize
      let result: IVerifyResult = {hadError:false, messages:[]};

      // check each data field
      //TODO add validity checks here (e.g. verify legal currency code [or use "picklist" to provide values])

      return result;
    }   // verifyAllDataValues

}   // class CSettings