export interface IVerifyResult {
	hadError: boolean,
	messages: string[]
}

export class CValidityCheck {

    constructor () { }

  	public static checkInteger(object:any, item:string, result:IVerifyResult) {
  		let str = String(object[item]);
  		if (!str.match(/^[0-9]+$/)) {
  			result.hadError = true;
  			result.messages.push('Must enter whole number value for ' + item);
  		}
  	}   // checkInteger

    public static checkInteger2(object:any, lev1:string, lev2:string, result:IVerifyResult) {
      let str = String(object[lev1][lev2]);
      if (!str.match(/^[0-9]+$/)) {
        result.hadError = true;
        result.messages.push('Must enter whole number value for ' + lev1 + '.' + lev2);
      }
    }   // checkInteger2

}