import { CValidityCheck, IVerifyResult } from './validity-check.class';

export class GenericDataManagement
/*
This class provides variables and routines for managing generic data processing.
*/
{
    // this data controls visibility of components in HTML
    showAllTypes: boolean;
    showAllFields: boolean;
    wantHiddenFields: boolean;

    areTypesVisible: any;
    areFieldsVisible: any;

    // this data supports presentation of data on the screen
    currentSubcategories: string[] = [];
    currentTypes: any = {};
    currentFields: any = {};

    constructor (public category:any, public possibleCategory:any, private messages:string[])
    {
        this.currentSubcategories = this.getSubcategories(this.category);
        this.currentTypes = this.getTypes(this.category);
        this.currentFields = this.getFields(this.category);

        let initialStatus = false;  // default initial status of visibility

        this.showAllTypes = initialStatus;
        this.showAllFields = initialStatus;
        this.wantHiddenFields = false;

        this.areTypesVisible = this.createAreTypesVisible(initialStatus);
        this.areFieldsVisible = this.createAreFieldsVisible(initialStatus);
    }   // constructor

    getSubcategories(category:any): string[]
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

    getTypes(category:any): any
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

    getFields(category:any): any
    /*
    This routine returns an object that has a list of field properties for all possible subcat and type values.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            result[subcat] = {};
            for (let type of Object.keys(this.category[subcat]))
            {
                if (type != 'label')
                {
                    for (let field of Object.keys(this.category[subcat][type]))
                    {
                        result[subcat][type] = [];
                        for (let field of Object.keys(this.category[subcat][type]))
                        {
                            if (this.wantHiddenFields || (field != 'label' && field != 'monthlyAmount')) result[subcat][type].push(field);
                        }
                    }
                }
            }
        }
        return result;
    }   // getFields

    getTypesList(category:any, subcat:string): string[]
    /*
    This routine returns a list of types under a given subcategory.
    */
    {
        let result = [];
        let typesInfo = this.getTypes(category);
        if (typesInfo.hasOwnProperty(subcat)) result = typesInfo[subcat];
        return result;
    }   // getTypesList

    getFieldsList(category:any, subcat:string, type:string): string[]
    /*
    This routine returns a list of fields under a given subcategory and type.
    */
    {
        let result = [];
        let fieldsInfo = this.getFields(category);
        if (fieldsInfo.hasOwnProperty(subcat) && fieldsInfo[subcat].hasOwnProperty(type))
        {
            result = fieldsInfo[subcat][type];
        }
        return result;
    }   // getFieldsList

    updateFieldsVisibility(): void
    {
        for (let subcat of Object.keys(this.areFieldsVisible))
        {
            for (let type of Object.keys(this.areFieldsVisible[subcat]))
            {
                this.areFieldsVisible[subcat][type] = this.showAllFields;
            }
        }
    }   // updateFieldsVisibility

    createAreTypesVisible(status:boolean): any
    /*
    This routine creates the data structure used to control the HTML visibility of types.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            result[subcat] = status;
        }
        return result;
    }   // createAreTypesVisible

    updateTypesVisibility()
    {
        for (let subcat of Object.keys(this.areTypesVisible))
        {
            this.areTypesVisible[subcat] = this.showAllTypes;
        }
    }   // updateTypesVisibility

    toggleTypeVisibility(subcat:string): void
    {
        this.areTypesVisible[subcat] = !this.areTypesVisible[subcat];
    }   // toggleTypeVisibility

    isTypeVisible(subcat:string): boolean
    {
        return this.areTypesVisible[subcat];
    }   // isTypeVisible

    createAreFieldsVisible(status:boolean): any
    /*
    This routine creates the data structure used to control the HTML visibility of fields.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            result[subcat] = {};
            for (let type of Object.keys(this.category[subcat]))
            {
                result[subcat][type] = status;
            }
        }
        return result;
    }   // createAreFieldsVisible

    toggleFieldVisibility(subcat:string, type:string): void
    {
        this.areFieldsVisible[subcat][type] = !this.areFieldsVisible[subcat][type];
    }   // toggleFieldVisibility

    isFieldVisible(subcat:string, type:string): boolean
    {
        return this.areFieldsVisible[subcat][type];
    }   // isFieldVisible

    updateHiddenFieldsVisibility(): void
    {
        this.currentFields = this.getFields(this.category);
    }   // updateHiddenFieldsVisibility

    dataType(val:any): any
    /*
    This routine automatically determines the type (number or string) for an input control
    */
    {
        return (typeof val == 'number' || (typeof val == 'string' && !isNaN(+val))) ? 'number' : 'string';
    }   // dataType

    getSubcategorySum(subcat:string): number
    /*
    This routine computes the sum of "monthlyAmount" values within a given subcategory.
    */
    {
        let sum = 0;
        for (let type of Object.keys(this.category[subcat]))
        {
            if (typeof this.category[subcat][type] == 'object' && this.category[subcat][type].hasOwnProperty('monthlyAmount'))
            {
                let val = this.category[subcat][type]['monthlyAmount'];
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

    getCategorySum(): number
    /*
    This routine computes the sum of "monthlyAmount" values within a given category.
    */
    {
        let sum = 0;
        for (let subcat of Object.keys(this.category))
        {
            for (let type of Object.keys(this.category[subcat]))
            {
                if (typeof this.category[subcat][type] == 'object' && this.category[subcat][type].hasOwnProperty('monthlyAmount'))
                {
                    let val = this.category[subcat][type]['monthlyAmount'];
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
    /*
    This routine will check the validity of all "monthlyAmount" values within the given category.
    */
    {
  		// initialize
  		let result: IVerifyResult = {hadError:false, messages:[]};

        for (let subcat of Object.keys(this.category))
        {
            for (let type of Object.keys(this.category[subcat]))
            {
                if (typeof this.category[subcat][type] == 'object' && this.category[subcat][type].hasOwnProperty('monthlyAmount'))
                {
                    CValidityCheck.checkInteger3(this.category,subcat,type,'monthlyAmount',result);
                }
            }
        }

    	return result;
  	}   // verifyAllDataValues

}   // class GenericDataManagement