import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { possibleAssets } from './assets.data'

export class CAssets
{

    constructor (public assets)
    {
        //possibleAssetSubcategories = this.
    }

    getAssetSubcategories(assets)
    {
          let result = [];
          for (var subcat of Object.keys(assets))
          {
              result.push(subcat);
          }
        return result;
    }  // getAssetSubcategories

    getAssetTypes(assets)
    {
        let result = {};
        for (var subcat of Object.keys(assets))
        {
            result[subcat] = [];
            for (var type of Object.keys(assets[subcat]))
            {
            result[subcat].push(type);
            }
        }
        return result;
    }   // getAssetTypes

    getSubcatListForSubcat(action:string): string[]
    {
      let possibleSubcat: string[];
      let currentSubcat: string[];
      let result: string[] = [];

      // build list of possible subcategories to add (possiblelist - currentlist)
      if (action == 'Add')
      {
          possibleSubcat = this.getAssetSubcategories(possibleAssets);
          currentSubcat = this.getAssetSubcategories(this.assets);
          for (let subcat of possibleSubcat)
          {
              if (currentSubcat.indexOf(subcat) == -1) result.push(subcat);
          }
          result.push('custom');
      }

      // build list of possible subcategories to delete (currentlist)
      if (action == 'Delete')
      {
          result = this.getAssetSubcategories(this.assets);
      }
      return result;
    }   // getSubcatListForSubcat

    getTypeListForSubcat(subcat:string, action:string): string[]
    {
        let result = [];

        // build list of possible types to add (possibleList)
        if (action == 'Add')
        {
            let possibleTypes = this.getAssetTypes(possibleAssets);
            result = possibleTypes[subcat];
        }

        if (action == 'Delete')
        {
            result = [];
        }
        return result;
    }   // getTypeListForSubcat

    getSubcatListForType(action:string)
    {
        let result = [];

        if (action == 'Add')
        {

        }
        if (action == 'Delete')
        {

        }
        return result;
    }   // getSubcatListForType

    getTypeListForType(subcat:string, action:string)
    {
        let result = {};

        if (action == 'Add')
        {

        }
        if (action == 'Delete')
        {

        }
        return result;
    }   // getTypeListForType

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