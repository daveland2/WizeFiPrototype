import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { possibleExpenses } from './expenses.data'

export class CExpenses
{
    constructor (public expenses)
    {
    }

    getSubcategories(expenses:any): string[]
    /*
    This routine returns an array containing a list of subcategory properties.
    */
    {
        let result = [];
        for (var subcat of Object.keys(expenses))
        {
            result.push(subcat);
        }
        return result;
    }  // getSubcategories

    getTypes(expenses:any): any
    /*
    This routine returns an object that has a list of type properties for all possible subcat values.
    */
    {
        let result = {};
        for (let subcat of Object.keys(expenses))
        {
            result[subcat] = [];
            for (let type of Object.keys(expenses[subcat]))
            {
                if (type != 'label') result[subcat].push(type);
            }
        }
        return result;
    }   // getTypes

    getFields(expenses:any): any
    /*
    This routine returns an object that has a list of field properties for all possible subcat and type values.
    */
    {
        let result = {};
        for (let subcat of Object.keys(expenses))
        {
            result[subcat] = {};
            for (let type of Object.keys(expenses[subcat]))
            {
                if (type != 'label')
                {
                    result[subcat][type] = [];
                    for (let field of Object.keys(expenses[subcat][type]))
                    {
                        if (field != 'label' && field != 'monthlyAmount') result[subcat][type].push(field);
                    }
                }
            }
        }
        return result;
    }   // getFields

    getTypesList(expenses:any, subcat:string): string[]
    /*
    This routine returns a list of types under a given subcategory.
    */
    {
        let result = [];
        let typesInfo = this.getTypes(expenses);
        if (typesInfo.hasOwnProperty(subcat)) result = typesInfo[subcat];
        return result;
    }   // getTypesList

    getFieldsList(expenses:any, subcat:string, type:string): string[]
    /*
    This routine returns a list of fields under a given subcategory and type.
    */
    {
        let result = [];
        let fieldsInfo = this.getFields(expenses);
        if (fieldsInfo.hasOwnProperty(subcat) && fieldsInfo[subcat].hasOwnProperty(type))
        {
            result = fieldsInfo[subcat][type];
        }
        return result;
    }   // getTypesList

    getUpdateSubcategoryList(item,action)
    {
        let currentSubcatList: string[] = this.getSubcategories(this.expenses);
        let possibleSubcatList: string[] = this.getSubcategories(possibleExpenses);
        let result: string[] = [];

        // build list of possible subcategories that are not in current subcategories
        let addableSubcatList: string[] = [];
        for (let subcat of possibleSubcatList)
        {
            if (currentSubcatList.indexOf(subcat) == -1) addableSubcatList.push(subcat);
        }
        addableSubcatList.push('custom');

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                result = addableSubcatList;
            }

            if (action == 'Delete')
            {
                result = currentSubcatList;
            }
        }

        if (item == 'Type')
        {
            if (action == 'Add')
            {
                result = currentSubcatList;
            }

            if (action == 'Delete')
            {
                result = currentSubcatList;
            }
        }

        return result;
    }   // getUpdateSubcategoryList

    getUpdateTypeList(item,action,subcat)
    {
        let currentTypeList: string[] = this.getTypesList(this.expenses, subcat);
        let possibleTypeList: string[] = this.getTypesList(possibleExpenses, subcat);
        let result: string[] = [];

        // build list of possible types that are not in current types
        let addableTypeList: string[] = [];
        for (let type of possibleTypeList)
        {
            if (currentTypeList.indexOf(type) == -1) addableTypeList.push(type);
        }
        addableTypeList.push('custom');

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                result = addableTypeList;
            }
            if (action == 'Delete')
            {
                result = [];
            }
        }

        if (item == 'Type')
        {
            if (action == 'Add')
            {
              result = addableTypeList;
            }

            if (action == 'Delete')
            {
                result = currentTypeList;
            }
        }

        return result;
    }   // getUpdateTypeList

    getSubcategorySum(subcat)
    {
        let sum = 0;
        for (let type of Object.keys(this.expenses[subcat]))
        {
            if (typeof this.expenses[subcat][type] == 'object' && this.expenses[subcat][type].hasOwnProperty('monthlyAmount'))
            {
                let val = this.expenses[subcat][type]['monthlyAmount'];
                if (typeof val == 'number')
                {
                    sum = sum + val;
                }
                else if (typeof val == 'string' && !isNaN(+val))
                {
                    sum = sum + Number(val);
                }
            }
        }
        return sum;
    }   // getSubcategorySum

    getCategorySum()
    {
        let sum = 0;
        for (let subcat of Object.keys(this.expenses))
        {
            for (let type of Object.keys(this.expenses[subcat]))
            {
                if (typeof this.expenses[subcat][type] == 'object' && this.expenses[subcat][type].hasOwnProperty('monthlyAmount'))
                {
                    let val = this.expenses[subcat][type]['monthlyAmount'];
                    if (typeof val == 'number')
                    {
                        sum = sum + val;
                    }
                    else if (typeof val == 'string' && !isNaN(+val))
                    {
                        sum = sum + Number(val);
                    }
                }
            }
        }
        return sum;
    }   // getCategorySum

  	verifyAllDataValues(): IVerifyResult
    {
  		// initialize
  		let result: IVerifyResult = {hadError:false, messages:[]};

        for (let subcat of Object.keys(this.expenses))
        {
            for (let type of Object.keys(this.expenses[subcat]))
            {
                CValidityCheck.checkInteger3(this.expenses,subcat,type,result);
            }
        }

    	return result;
  	}   // verifyAllDataValues

}   // class CExpenses