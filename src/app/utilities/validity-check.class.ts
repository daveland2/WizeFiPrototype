export interface IVerifyResult
{
	hadError: boolean,
	messages: string[]
}

export class CValidityCheck
{

    constructor () { }

  	public static checkInteger(object:any, item:string, result:IVerifyResult)
    {
    		let str = String(object[item]);
    		if (!str.match(/^[0-9]+$/))
        {
    			result.hadError = true;
    			result.messages.push('Must enter whole number value for ' + item);
    		}
  	}   // checkInteger

    public static checkInteger2(object:any, lev1:string, lev2:string, result:IVerifyResult)
    {
        let str = String(object[lev1][lev2]);
        if (!str.match(/^[0-9]+$/))
        {
          result.hadError = true;
          result.messages.push('Must enter whole number value for ' + lev1 + '.' + lev2);
        }
    }   // checkInteger2

    public static checkInteger3(object:any, lev1:string, lev2:string, lev3:string, result:IVerifyResult)
    {
        let str = String(object[lev1][lev2][lev3]);
        if (!str.match(/^[0-9]+$/))
        {
          result.hadError = true;
          result.messages.push('Must enter whole number value for ' + lev1 + '.' + lev2 + '.' + lev3);
        }
    }   // checkInteger3

    public static checkInteger4(object:any, lev1:string, ndx:number, lev3:string, result:IVerifyResult)
    {
        let str = String(object[lev1].accounts[ndx][lev3]);
        if (!str.match(/^[0-9]+$/))
        {
          result.hadError = true;
          result.messages.push('Must enter whole number value for ' + lev1 + '[' + ndx + '].' + lev3);
        }
    }   // checkInteger4

    public static checkAttributeNameValidity(attributeName:string, val:string, messages:string[]): boolean
    {
        let hadError = false;
        let attrbiuteNamePattern = /^([a-zA-Z][a-zA-Z0-9_]*)$/;
        if (!val.match(attrbiuteNamePattern))
        {
            hadError = true;
            messages.push("Attribute name for " + attributeName + " must start with a letter, and contain only letters, digits, or underscore");
        }
        return hadError;
    }   // checkAttributeNameValidity
}