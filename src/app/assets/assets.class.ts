import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';

export interface IAssets
{
}

export class CAssets
{

    constructor (public assets: IAssets) { }

    getSubcategorySum(subcat)
    {
        let sum = 0;
        for (var type of Object.keys(this.assets[subcat]))
        {
            sum = sum + this.assets[subcat][type];
        }
        return sum;
  	}   // getSubcategorySum

    getCategorySum()
    {
        let sum = 0;
        for (var subcat of Object.keys(this.assets))
        {
            for (var type of Object.keys(this.assets[subcat]))
            {
                sum = sum + this.assets[subcat][type];
            }
        }
        return sum;
    }   // getCategorySum

  	verifyAllDataValues(): IVerifyResult
    {
    		// initialize
    		let result: IVerifyResult = {hadError:false, messages:[]};

        for (var subcat of Object.keys(this.assets))
        {
            for (var type of Object.keys(this.assets[subcat]))
            {
                CValidityCheck.checkInteger2(this.assets,subcat,type,result);
            }
        }

    		return result;
  	}   // verifyAllDataValues

}   // class CAssets