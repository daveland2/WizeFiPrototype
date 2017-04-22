import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { possibleExpenses } from './expenses.data'

export class CExpenses
{

    constructor (public expenses)
    {
        //possibleExpenseSubcategories = this.
    }

    getExpenseSubcategories(expenses:any): string[]
    {
          let result = [];
          for (var subcat of Object.keys(expenses))
          {
              result.push(subcat);
          }
        return result;
    }  // getExpenseSubcategories

    getExpenseTypes(expenses:any): any
    {
        let result = {};
        for (var subcat of Object.keys(expenses))
        {
            result[subcat] = [];
            for (var type of Object.keys(expenses[subcat]))
            {
            result[subcat].push(type);
            }
        }
        return result;
    }   // getExpenseTypes

    getSubcatListForSubcat(action:string): string[]
    {
      let possibleSubcat: string[];
      let currentSubcat: string[];
      let result: string[] = [];

      // build list of possible subcategories to add (possiblelist - currentlist)
      if (action == 'Add')
      {
          possibleSubcat = this.getExpenseSubcategories(possibleExpenses);
          currentSubcat = this.getExpenseSubcategories(this.expenses);
          for (let subcat of possibleSubcat)
          {
              if (currentSubcat.indexOf(subcat) == -1) result.push(subcat);
          }
          result.push('custom');
      }

      // build list of possible subcategories to delete (currentlist)
      if (action == 'Delete')
      {
          result = this.getExpenseSubcategories(this.expenses);
      }
      return result;
    }   // getSubcatListForSubcat

    getTypeListForSubcat(subcat:string, action:string): string[]
    {
        let result = [];

        // build list of possible types to add (possibleList)
        if (action == 'Add')
        {
            let possibleTypes = this.getExpenseTypes(possibleExpenses);
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
        for (var type of Object.keys(this.expenses[subcat]))
        {
            sum = sum + this.expenses[subcat][type];
        }
        return sum;
  	}   // getSubcategorySum

    getCategorySum()
    {
        let sum = 0;
        for (var subcat of Object.keys(this.expenses))
        {
            for (var type of Object.keys(this.expenses[subcat]))
            {
                sum = sum + this.expenses[subcat][type];
            }
        }
        return sum;
    }   // getCategorySum

  	verifyAllDataValues(): IVerifyResult
    {
    		// initialize
    		let result: IVerifyResult = {hadError:false, messages:[]};

        for (var subcat of Object.keys(this.expenses))
        {
            for (var type of Object.keys(this.expenses[subcat]))
            {
                CValidityCheck.checkInteger2(this.expenses,subcat,type,result);
            }
        }

    		return result;
  	}   // verifyAllDataValues

}   // class CExpenses