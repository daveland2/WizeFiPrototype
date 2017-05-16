import { Generic2DataManagement } from './generic2-data-management.class';
import { CValidityCheck } from '../utilities/validity-check.class';

export class Item2Management
/*
This class provides variables and routines for item management (adding and deleting items in data model).
*/
{
    selectedItem: string;
    selectedAction: string;

    // the following data consists of JavaScript attribute names
    subcatList: string[] = [];
    selectedSubcategory: string;
    customSubcategory: string = '';

    // the following data consists of accountName values
    accountList: string[] = [];
    selectedAccount: string;
    customAccount: string = '';

    // the following data consists of JavaScript attribute names
    fieldList: string[] = [];
    selectedField: string;
    customField: string = '';

    constructor (private gd:Generic2DataManagement, private messages:string[])
    {
        this.selectedItem = 'Subcategory';
        this.selectedAction = 'Delete'; //%//  set to Add later

        // update subcategories list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];

        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
    }   // constructor

    onItemChange(): void
    {
        // update subcategories list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];
        this.customSubcategory = '';

        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];
        this.customAccount = '';

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
        this.customField = '';
    }   // onItemChange

    onActionChange(): void
    {
        // update subcategories list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];
        this.customSubcategory = '';

        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];
        this.customAccount = '';

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
        this.customField = '';
    }   // onActionChange

    onSubcategoryChange(): void
    {
        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
    }   // onSubcategoryChange

    onAccountChange(): void
    {
        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
    }   // onAccountChange

    onFieldChange(): void
    {
        // no action required
    }   // onFieldChange

    getUpdateSubcategoryList(currentCategory:any, possibleCategory:any, item:string, action:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the subcategories drop down list.
    */
    {
        let currentSubcatList: string[] = this.gd.getSubcategories(currentCategory);
        let possibleSubcatList: string[] = this.gd.getSubcategories(possibleCategory);
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

        if (item == 'Account')
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

    getUpdateAccountList(currentCategory:any, possibleCategory:any, item:string, action:string, subcat:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the accounts drop down list in the Manage Items feature.
    */
    {
        let currentAccountList: string[] = this.gd.getAccountsList(currentCategory, subcat);
        let possibleAccountList: string[] = this.gd.getAccountsList(possibleCategory, subcat);
        let result: string[] = [];

        // build list of possible accounts that are not in current accounts
        let addableAccountList: string[] = [];
        if (subcat != 'custom')
        {
            for (let accountName of possibleAccountList)
            {
                if (currentAccountList.indexOf(accountName) == -1) addableAccountList.push(accountName);
            }
        }
        addableAccountList.push('custom');

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
              result = addableAccountList;
            }

            if (action == 'Delete')
            {
                result = [];
            }
        }

        if (item == 'Account')
        {
            if (action == 'Add')
            {
              result = addableAccountList;
            }

            if (action == 'Delete')
            {
                result = currentAccountList;
            }
        }

        if (item == 'Field')
        {
            if (action == 'Add')
            {
              result = currentAccountList;
            }

            if (action == 'Delete')
            {
                result = currentAccountList;
            }
        }

        return result;
    }   // getUpdateAccountList

    getUpdateFieldList(currentCategory:any, possibleCategory:any, item:string, action:string, subcat:string, accountName:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the fields drop down list in the Manage Items feature.
    */
    {
        let currentFieldList: string[] = this.gd.getFieldsList(currentCategory, subcat, accountName);
        let possibleFieldList: string[] = this.gd.getFieldsList(possibleCategory, subcat, accountName);
        let result: string[] = [];

        // build list of possible fields that are not in current fields
        let addableFieldList: string[] = [];
        if (subcat != 'custom' && accountName != 'custom')
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

        if (item == 'Account')
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

    public static doAction
    (
        gd: Generic2DataManagement,
        item: string,
        action: string,
        subcat: string,
        accountName: string,
        field: string
    ): void
    {

        let actndx: number;

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                /*
                actndx = 0;
                gd.category[subcat] = {};
                gd.category[subcat].label = subcat;
                gd.category[subcat].accounts = [];
                gd.category[subcat].accounts.push({});  //%//
                gd.category[subcat].accounts[actndx] = {};  //%//
                if (field != 'none') gd.category[subcat].accounts[actndx][field] = {};  //%//
                */  //*//
            }

            if (action == 'Delete')
            {
                delete gd.category[subcat];
            }
        }   // Subcategory

        if (item == 'Account')
        {
            if (action == 'Add')
            {
                /*
                gd.category[subcat].accounts.push({});
                gd.category[subcat][account]['label'] = accountName;
                gd.category[subcat][account]['monthlyAmount'] = 0;
                if (field != 'none') gd.category[subcat][account][field] = '';
                */  //%//
            }

            if (action == 'Delete')
            {
                //TODO review how to delete element from array
                // myArray.splice(startndx,numelements);
                // myArray.splice(2,1);
                actndx = gd.getActndx(subcat,accountName);
                gd.category[subcat].accounts.splice(actndx,1);
            }
        }   // Account

        if (item == 'Field')
        {
            if (action == 'Add')
            {
                /*
                gd.category[subcat][account][field] = '';
                */  //%//
            }

            if (action == 'Delete')
            {
                actndx = gd.getActndx(subcat,accountName);
                delete gd.category[subcat].accounts[actndx][field];
            }
        }   // Field
    }   // doAction

    performAction(): void
    /*
    This routine performs the specified action requested in the "Manage Items" section.
    The code is factored to separate those parts that are interacting with the screen,
    and those that are carrying out dataModel changes (done in the doAction routine).
    */
    {
        let wantRefresh: boolean = true;
        let hadError: boolean = false;
        let item: string = this.selectedItem;
        let action: string = this.selectedAction;
        let subcat: string = this.selectedSubcategory;
        let accountName: string = this.selectedAccount;
        let field: string = this.selectedField;

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                /*
                if (subcat == 'custom') subcat = this.customSubcategory
                if (account == 'custom') account = this.customAccount;
                if (field == 'custom') field = this.customField;

                if (CValidityCheck.checkAttributeNameValidity('subcat', subcat, this.messages)) hadError = true;
                if (CValidityCheck.checkAttributeNameValidity('account', account, this.messages)) hadError = true;
                if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;
                */  //%//
            }

            if (action == 'Delete')
            {
                if (!confirm('Do you intend to delete the subcategory: ' + subcat))
                {
                    wantRefresh = false;
                }
            }
        }   // Subcategory

        if (item == 'Account')
        {
            if (action == 'Add')
            {
                /*
                if (account == 'custom') account = this.customAccount;
                if (field == 'custom') field = this.customField;

                if (CValidityCheck.checkAttributeNameValidity('account', account, this.messages)) hadError = true;
                if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;
                */
            }

            if (action == 'Delete')
            {
                if (!confirm('Do you intend to delete the account: ' + subcat + '->' + accountName))
                {
                    wantRefresh = false;
                }
            }
        }   // Account

        if (item == 'Field')
        {
            if (action == 'Add')
            {
                /*
                if (field == 'none')
                {
                    wantRefresh = false;
                }
                else
                {
                    if (field == 'custom') field = this.customField;
                    if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;
                }
                */  //%//
            }

            if (action == 'Delete')
            {
                if (!confirm('Do you intend to delete the field: '+subcat+'->'+accountName+'->'+field))
                {
                    wantRefresh = false;
                }
            }
        }   // Field

        // update screen
        if (wantRefresh && !hadError)
        {
            // make changes to the screen data model behind the scenes
            Item2Management.doAction(this.gd, item, action, subcat, accountName, field);

            // update screen to reflect changes in the data model
            this.gd.areAccountsVisible = this.gd.createAreAccountsVisible(this.gd.showAllAccounts);
            this.gd.areFieldsVisible = this.gd.createAreFieldsVisible(this.gd.showAllFields);
            this.gd.currentSubcategories = this.gd.getSubcategories(this.gd.category);
            this.gd.currentAccounts = this.gd.getAccounts(this.gd.category);
            this.gd.currentFields = this.gd.getFields(this.gd.category);
        }
    }   // performAction

}   // class ItemManagement