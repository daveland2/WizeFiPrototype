import { CValidityCheck, IVerifyResult } from './validity-check.class';

export class GD
/*
This class provides routines for managing generic data processing.
*/
{
    public static getSubcategories(category:any): string[]
    /*
    This routine returns an array containing a list of subcategory properties.
    */
    {
        let result = [];
        for (var subcat of Object.keys(category))
        {
            result.push(subcat);
        }
        return result;
    }  // getSubcategories

    public static getTypes(category:any): any
    /*
    This routine returns an object that has a list of type properties for all possible subcat values.
    */
    {
        let result = {};
        for (let subcat of Object.keys(category))
        {
            result[subcat] = [];
            for (let type of Object.keys(category[subcat]))
            {
                if (type != 'label') result[subcat].push(type);
            }
        }
        return result;
    }   // getTypes

    public static getFields(category:any, wantHiddenFields:boolean): any
    /*
    This routine returns an object that has a list of field properties for all possible subcat and type values.
    */
    {
        let result = {};
        for (let subcat of Object.keys(category))
        {
            result[subcat] = {};
            for (let type of Object.keys(category[subcat]))
            {
                if (type != 'label')
                {
                    for (let field of Object.keys(category[subcat][type]))
                    {
                        result[subcat][type] = [];
                        for (let field of Object.keys(category[subcat][type]))
                        {
                            if (wantHiddenFields || (field != 'label' && field != 'monthlyAmount')) result[subcat][type].push(field);
                        }
                    }
                }
            }
        }
        return result;
    }   // getFields

    public static getTypesList(category:any, subcat:string): string[]
    /*
    This routine returns a list of types under a given subcategory.
    */
    {
        let result = [];
        let typesInfo = this.getTypes(category);
        if (typesInfo.hasOwnProperty(subcat)) result = typesInfo[subcat];
        return result;
    }   // getTypesList

    public static getFieldsList(category:any, subcat:string, type:string, wantHiddenFields:boolean): string[]
    /*
    This routine returns a list of fields under a given subcategory and type.
    */
    {
        let result = [];
        let fieldsInfo = this.getFields(category,wantHiddenFields);
        if (fieldsInfo.hasOwnProperty(subcat) && fieldsInfo[subcat].hasOwnProperty(type))
        {
            result = fieldsInfo[subcat][type];
        }
        return result;
    }   // getFieldsList

    public static getUpdateSubcategoryList(currentCategory:any, possibleCategory:any, item:string, action:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the subcategories drop down list.
    */
    {
        let currentSubcatList: string[] = this.getSubcategories(currentCategory);
        let possibleSubcatList: string[] = this.getSubcategories(possibleCategory);
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

        if (item == 'Field')
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

    public static getUpdateTypeList(currentCategory:any, possibleCategory:any, item:string, action:string, subcat:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the types drop down list in the Manage Items feature.
    */
    {
        let currentTypeList: string[] = this.getTypesList(currentCategory, subcat);
        let possibleTypeList: string[] = this.getTypesList(possibleCategory, subcat);
        let result: string[] = [];

        // build list of possible types that are not in current types
        let addableTypeList: string[] = [];
        if (subcat != 'custom')
        {
            for (let type of possibleTypeList)
            {
                if (currentTypeList.indexOf(type) == -1) addableTypeList.push(type);
            }
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

        if (item == 'Field')
        {
            if (action == 'Add')
            {
              result = currentTypeList;
            }

            if (action == 'Delete')
            {
                result = currentTypeList;
            }
        }

        return result;
    }   // getUpdateTypeList

    public static getUpdateFieldList(currentCategory:any, possibleCategory:any, item:string, action:string, subcat:string, type:string, wantHiddenFields:boolean): string[]
    /*
    This routine creates a list that provides the appropriate content for the fields drop down list in the Manage Items feature.
    */
    {
        let currentFieldList: string[] = this.getFieldsList(currentCategory, subcat, type, wantHiddenFields);
        let possibleFieldList: string[] = this.getFieldsList(possibleCategory, subcat, type, wantHiddenFields);
        let result: string[] = [];

        // build list of possible fields that are not in current fields
        let addableFieldList: string[] = [];
        if (subcat != 'custom' && type != 'custom')
        {
            for (let field of possibleFieldList)
            {
                if (currentFieldList.indexOf(field) == -1) addableFieldList.push(field);
            }
        }
        addableFieldList.push('none');
        addableFieldList.push('custom');

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                result = addableFieldList;
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
              result = addableFieldList;
            }

            if (action == 'Delete')
            {
                result = [];
            }
        }

        if (item == 'Field')
        {
            if (action == 'Add')
            {
              result = addableFieldList;
            }

            if (action == 'Delete')
            {
                result = currentFieldList;
            }
        }

        return result;
    }   // getUpdateFieldList

    public static createAreTypesVisible(category:any, status:boolean): any
    /*
    This routine creates the data structure used to control the HTML visibility of subcategories.
    */
    {
        let result = {};
        for (let subcat of Object.keys(category))
        {
            result[subcat] = status;
        }
        return result;
    }   // createAreTypesVisible

    public static createAreFieldsVisible(category:any, status:boolean): any
    /*
    This routine creates the data structure used to control the HTML visibility of fields.
    */
    {
        let result = {};
        for (let subcat of Object.keys(category))
        {
            result[subcat] = {};
            for (let type of Object.keys(category[subcat]))
            {
                result[subcat][type] = status;
            }
        }
        return result;
    }   // createAreFieldsVisible

    public static getSubcategorySum(category:any, subcat:string): number
    /*
    This routine computes the sum of "monthlyAmount" values within a given subcategory.
    */
    {
        let sum = 0;
        for (let type of Object.keys(category[subcat]))
        {
            if (typeof category[subcat][type] == 'object' && category[subcat][type].hasOwnProperty('monthlyAmount'))
            {
                let val = category[subcat][type]['monthlyAmount'];
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

    public static getCategorySum(category:any): number
    /*
    This routine computes the sum of "monthlyAmount" values within a given category.
    */
    {
        let sum = 0;
        for (let subcat of Object.keys(category))
        {
            for (let type of Object.keys(category[subcat]))
            {
                if (typeof category[subcat][type] == 'object' && category[subcat][type].hasOwnProperty('monthlyAmount'))
                {
                    let val = category[subcat][type]['monthlyAmount'];
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

  	public static verifyAllDataValues(category:any): IVerifyResult
    /*
    This routine will check the validity of all "monthlyAmount" values within the given category.
    */
    {
  		// initialize
  		let result: IVerifyResult = {hadError:false, messages:[]};

        for (let subcat of Object.keys(category))
        {
            for (let type of Object.keys(category[subcat]))
            {
                if (typeof category[subcat][type] == 'object' && category[subcat][type].hasOwnProperty('monthlyAmount'))
                {
                    CValidityCheck.checkInteger3(category,subcat,type,'monthlyAmount',result);
                }
            }
        }

    	return result;
  	}   // verifyAllDataValues

}   // class GD