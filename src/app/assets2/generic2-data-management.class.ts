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
    currentSubcategories: string[] = [];
    currentAccounts: any = {};
    currentFields: any = {};

    constructor (public category:any, public possibleCategory:any, private messages:string[])
    {
        this.currentSubcategories = this.getSubcategories(this.category);
        this.currentAccounts = this.getAccounts(this.category);
        this.currentFields = this.getFields(this.category);

        let initialStatus = false;  // default initial status of visibility

        this.showAllAccounts = initialStatus;
        this.showAllFields = initialStatus;
        this.wantHiddenFields = false;

        this.areAccountsVisible = this.createAreAccountsVisible(initialStatus);
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
            if (subcat != 'label') result.push(subcat);
        }
        return result;
    }  // getSubcategories

    getAccounts(category:any): any
    /*
    This routine returns an object that has a list of account array subscript values under each subcat value.
    ===========>  should this return actndx values or accountName values?
    */
    {
        let result = {};
        for (let subcat of Object.keys(category))
        {
            if (subcat != 'label')
            {
                result[subcat] = [];
                for (let i = 0; i < category[subcat].accounts.length; i++)
                {
                    // result[subcat].push(i);  // return actndx
                    result[subcat].push(category[subcat].accounts[i].accountName);  // return accountName
                }
            }
        }
        return result;
    }   // getAccounts

    getFields(category:any): any
    /*
    This routine returns an object that has a list of field properties for all possible subcat and account values.
    */
    {
        let result = {};
        for (let subcat of Object.keys(this.category))
        {
            if (subcat != 'label')
            {
                result[subcat] = [];
                for (let i = 0; i < category[subcat].accounts.length; i++)
                {
                    result[subcat][i] = [];
                    for (let field of Object.keys(category[subcat].accounts[i]))
                    {
                        if (this.wantHiddenFields || (field != 'accountName' && field != 'accountType' && field != 'isRequired')) result[subcat][i].push(field);
                    }
                }
            }
        }
        return result;
    }   // getFields

    getAccountsList(category:any, subcat:string): string[]
    /*
    This routine returns a list of accounts under a given subcategory.
    */
    {
        let result = [];
        let accountsInfo = this.getAccounts(category);
        if (accountsInfo.hasOwnProperty(subcat)) result = accountsInfo[subcat];
        return result;
    }   // getAccountsList

    getFieldsList(category:any, subcat:string, actndx:number): string[]
    /*
    This routine returns a list of fields under a given subcategory and account.
    */
    {
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
            for (let i = 0; i < this.areFieldsVisible[subcat].accounts.length; i++)
            {
                this.areFieldsVisible[subcat].accounts[i] = this.showAllFields;
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
            result[subcat] = status;
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
            result[subcat] = [];
            for (let i = 0; i < this.category[subcat].accounts.length; i++)
            {
                result[subcat].push(status);
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
        for (let i = 0; i < this.category[subcat].accounts.length; i++)
        {
            if (typeof this.category[subcat].accounts[i] == 'object' && this.category[subcat].accounts[i].hasOwnProperty('monthlyAmount'))
            {
                let val = this.category[subcat].accounts[i].monthlyAmount.val;
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
            for (let i = 0; i < this.category[subcat].accounts.length; i++)
            {
                if (typeof this.category[subcat].accounts[i] == 'object' && this.category[subcat].accounts[i].hasOwnProperty('monthlyAmount'))
                {
                    let val = this.category[subcat].accounts[i].monthlyAmount.val;
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
            for (let i = 0; i < this.category[subcat].accounts.length; i++)
            {
                if (typeof this.category[subcat].accounts[i] == 'object' && this.category[subcat].accounts[i].hasOwnProperty('monthlyAmount'))
                {
                    CValidityCheck.checkInteger4(this.category,subcat,i,'monthlyAmount',result);
                }
            }
        }

    	return result;
  	}   // verifyAllDataValues

}   // class Generic2DataManagement