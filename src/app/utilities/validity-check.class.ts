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
  			result.messages.push('Must enter integer value for ' + item);
  		}
  	}   // checkInteger

}