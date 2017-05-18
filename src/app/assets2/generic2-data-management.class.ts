import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';  //%//

export class Generic2DataManagement
/*
This class provides variables and routines for managing generic data processing.
*/
{
    // this data controls visibility of components in HTML
    showAllAccounts: boolean;
    showAllFields: boolean;
    wantHiddenFields: boolean;

    areAccountsVisible: any;
    areFieldsVisible: any;

    // this data supports presentation of data on the screen
    currentSubcategories: any = [];
    currentAccounts: any = {};
    currentFields: any = {};

    constructor (public category:any, public possibleCategory:any, private messages:string[])
    {
        this.currentSubcategories = this.getSubcategories(this.category);
        this.currentAccounts = this.getAccounts(this.category);
        this.currentFields = this.getFields(this.category);

        let initialStatus = true;  // default initial status of visibility

        this.showAllAccounts = initialStatus;
        this.showAllFields = initialStatus;
        this.wantHiddenFields = false;

        this.areAccountsVisible = this.createAreAccountsVisible(initialStatus);
        this.areFieldsVisible = this.createAreFieldsVisible(initialStatus);
    }   // constructor

    isNumber(val): boolean
    {
        return typeof val === 'number';
    }

    isString(val): boolean
    {
        return typeof val === 'string';
    }

    isBoolean(val): boolean
    {
        return typeof val === 'boolean';
    }

    getActndx(category,subcat,accountName): number
    /*
    This function returns the subscript for the location of an accountName in the accounts array under a given subcategory.
    If the accountName is not present, the function returns 0 (this function is intended to be used in situations where)
    the accountName is known to be present).
    */
    {
        let actndx = category[subcat].accounts.length;
        while (--actndx > 0 && category[subcat].accounts[actndx].accountName.val != accountName);
        return actndx;
    }   // getActndx

    getSubcategories(category:any): any
    /*
    This routine returns an array containing a list of objects that contain subcategory attributes and labels.
    */
    {
        let result = [];
        for (let subcat of Object.keys(category))
        {
            if (subcat != 'attributeName' && subcat != 'label') result.push({subcat:subcat, label:category[subcat].label});
        }
        return result;
    }  // getSubcategories

    getAccounts(category:any): any
    /*
    This routine returns an object that has an array of accountName values under each subcat value.  In addition to making a list of the account names available, this list also identifies the number of accounts under a given subcatagory.  This value can be used to control a loop that iterates over each account under a subcategory.
    */
    {
        let result = {};
        for (let subcat of Object.keys(category))
        {
            if (subcat != 'attributeName' && subcat != 'label')
            {
                result[subcat] = [];
                for (let actndx = 0; actndx < category[subcat].accounts.length; actndx++)
                {
                    result[subcat].push(category[subcat].accounts[actndx].accountName.val);
                }
            }
        }
        return result;
    }   // getAccounts

    getFields(category:any): any
    /*
    This routine returns an object that contains for each subcat an array containing a list of objects that contain field attributes and labels.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            if (subcat != 'attributeName' && subcat != 'label')
            {
                result[subcat] = [];
                for (let actndx = 0; actndx < category[subcat].accounts.length; actndx++)
                {
                    result[subcat].push([]);
                    for (let field of Object.keys(category[subcat].accounts[actndx]))
                    {
                        if (this.wantHiddenFields || (field != 'accountName' && field != 'accountType' && field != 'isRequired')) result[subcat][actndx].push({field:field, label:category[subcat].accounts[actndx][field].label});
                    }
                }
            }
        }
        return result;
    }   // getFields

    getAccountsList(category:any, subcat:string): string[]
    /*
    This routine returns a list of account names under a given subcategory.
    */
    {
        let result = [];
        let accountsInfo = this.getAccounts(category);
        if (accountsInfo.hasOwnProperty(subcat)) result = accountsInfo[subcat];
        return result;
    }   // getAccountsList

    getFieldsList(category:any, subcat:string, accountName:string): any
    /*
    This routine returns an array of objects under a given subcategory and account (where the account is identified by the account name).  Each object contains a field attribute name and a field label.
    */
    {
        let actndx = this.getActndx(category,subcat,accountName);
        let result = [];
        let fieldsInfo = this.getFields(category);
        if (fieldsInfo.hasOwnProperty(subcat) && 0 <= actndx && actndx < fieldsInfo[subcat].length)
        {
            result = fieldsInfo[subcat][actndx];
        }
        return result;
    }   // getFieldsList

    updateFieldsVisibility(): void
    {
        for (let subcat of Object.keys(this.areFieldsVisible))
        {
            for (let i = 0; i < this.areFieldsVisible[subcat].length; i++)
            {
                this.areFieldsVisible[subcat][i] = this.showAllFields;
            }
        }
    }   // updateFieldsVisibility

    createAreAccountsVisible(status:boolean): any
    /*
    This routine creates the data structure used to control the HTML visibility of accounts.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            if (subcat != 'attributeName' && subcat != 'label')
            {
                result[subcat] = status;
            }
        }
        return result;
    }   // createAreAccountsVisible

    updateAccountsVisibility()
    {
        for (let subcat of Object.keys(this.areAccountsVisible))
        {
            this.areAccountsVisible[subcat] = this.showAllAccounts;
        }
    }   // updateAccountsVisibility

    toggleAccountVisibility(subcat:string): void
    {
        this.areAccountsVisible[subcat] = !this.areAccountsVisible[subcat];
    }   // toggleAccountVisibility

    isAccountVisible(subcat:string): boolean
    {
        return this.areAccountsVisible[subcat];
    }   // isAccountVisible

    createAreFieldsVisible(status:boolean): any
    /*
    This routine creates the data structure used to control the HTML visibility of fields.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            if (subcat != 'attributeName' && subcat != 'label')
            {
                result[subcat] = [];
                for (let actndx = 0; actndx < this.category[subcat].accounts.length; actndx++)
                {
                    result[subcat].push(status);
                }
            }
        }
        return result;
    }   // createAreFieldsVisible

    toggleFieldVisibility(subcat:string, actndx:number): void
    {
        this.areFieldsVisible[subcat][actndx] = !this.areFieldsVisible[subcat][actndx];
    }   // toggleFieldVisibility

    isFieldVisible(subcat:string, actndx:number): boolean
    {
        return this.areFieldsVisible[subcat][actndx];
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
        for (let actndx = 0; actndx < this.category[subcat].accounts.length; actndx++)
        {
            if (typeof this.category[subcat].accounts[actndx] == 'object' && this.category[subcat].accounts[actndx].hasOwnProperty('monthlyAmount'))
            {
                let val = this.category[subcat].accounts[actndx].monthlyAmount.val;
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
            if (subcat != 'attributeName' && subcat != 'label')
            {
                for (let actndx = 0; actndx < this.category[subcat].accounts.length; actndx++)
                {
                    if (typeof this.category[subcat].accounts[actndx] == 'object' && this.category[subcat].accounts[actndx].hasOwnProperty('monthlyAmount'))
                    {
                        let val = this.category[subcat].accounts[actndx].monthlyAmount.val;
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
            if (subcat != 'attributeName' && subcat != 'label')
            {
                for (let actndx = 0; actndx < this.category[subcat].accounts.length; actndx++)
                {
                    if (typeof this.category[subcat].accounts[actndx] == 'object' && this.category[subcat].accounts[actndx].hasOwnProperty('monthlyAmount'))
                    {
                        CValidityCheck.checkInteger4(this.category,subcat,actndx,'monthlyAmount',result);
                    }
                }
            }
        }

    	return result;
  	}   // verifyAllDataValues

}   // class Generic2DataManagement