import { Generic2DataManagement } from './generic2-data-management.class';
import { CValidityCheck } from '../utilities/validity-check.class';
import { possibleFieldNames,accountTypes,subcategoryInfo } from '../data-model/data-model_1.data';

export class Item2Management
/*
This class provides variables and routines for item management (adding and deleting items in data model).
*/
{
    selectedAction: string;
    selectedItem: string;
    selectedFieldSelection: string = 'Account type';

    // the following data consists of JavaScript attribute names
    subcatList: any = [];
    selectedSubcategory: string;
    customSubcategory: string = '';

    // the following data consists of accountName values
    accountList: string[] = [];
    selectedAccount: string;
    customAccount: string = '';

    // the following data consists of JavaScript attribute names
    fieldList: any = [];
    selectedField: string;
    customField: string = '';

    constructor (private gd:Generic2DataManagement, private messages:string[])
    {
        this.selectedAction = 'Delete';
        this.selectedItem = 'Subcategory';

        // update subcategory list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0].subcat;

        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
    }   // constructor

    onActionChange(): void
    {
        // update subcategory list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0].subcat;
        this.customSubcategory = '';

        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];
        this.customAccount = '';

        // update field list
        if (this.selectedAction == 'Add')
        {
            this.selectedFieldSelection = 'Account type';
        }
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
        this.customField = '';
    }   // onActionChange

    onItemChange(): void
    {
        // update subcategory list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0].subcat;
        this.customSubcategory = '';

        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];
        this.customAccount = '';

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
        this.customField = '';
    }   // onItemChange

    onSubcategoryChange(): void
    {
        // update account list
        this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
    }   // onSubcategoryChange

    onAccountChange(): void
    {
        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
    }   // onAccountChange

    onFieldSelectionChange()
    {
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
    }   // onFieldSelectionChange

    onFieldChange(): void
    {
        // no action required
    }   // onFieldChange

    subcategoryListContains(subcatList:any, subcat:string): boolean
    {
        let result = false;
        let i = subcatList.length;
        while (--i >= 0 && !result) result = (subcatList[i].subcat == subcat);
        return result;
    }   // subcategoryListContains

    fieldListContains(fieldList:any, field:string): boolean
    {
        let result = false;
        let i = fieldList.length;
        while (--i >= 0 && !result) result = (fieldList[i].field == field);
        return result;
    }   // fieldListContains

    getUpdateSubcategoryList(currentCategory:any, possibleCategory:any, item:string, action:string): any
    /*
    This routine creates a list that provides the appropriate content for the subcategories drop down list.
    */
    {
        let currentSubcatList: any = this.gd.getSubcategories(currentCategory);
        let possibleSubcatList: any = this.gd.getSubcategories(possibleCategory);
        let result: any = [];

        // build list of possible subcategories that are not in current subcategories
        let addableSubcatList: any = [];
        for (let subcatobj of possibleSubcatList)
        {
            if (!this.subcategoryListContains(currentSubcatList, subcatobj.subcat)) addableSubcatList.push(subcatobj);
        }
        addableSubcatList.push({subcat:'custom', label:'custom'});

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
                // result = addableAccountList;
                result = subcategoryInfo[this.gd.category.attributeName][subcat].accountNames;
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
        let currentFieldList: any = this.gd.getFieldsList(currentCategory, subcat, accountName);
        let possibleFieldList: any = this.gd.getFieldsList(possibleCategory, subcat, accountName);
        let result: any[] = [];
        let actndx: number;
        let accountType: string;

        // build list of possible fields that are not in current fields
        let addableFieldList: any = [];
        if (subcat != 'custom' && accountName != 'custom')
        {
            actndx = this.gd.getActndx(possibleCategory, subcat, accountName);
            for (let fieldobj of possibleFieldList)
            {
                if (!this.fieldListContains(currentFieldList, fieldobj.field)) addableFieldList.push(fieldobj);
            }
        }
        addableFieldList.push({field:'none', label:'none'});   //%//  eliminate this?
        addableFieldList.push({field:'custom', label:'custom'});

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
                // result = addableFieldList;
                // for now assume at most one account type can be associated with a subcategory
                accountType = subcategoryInfo[this.gd.category.attributeName][subcat].accountTypes[0];
                result.push({field:accountType, label:accountType});
                this.selectedFieldSelection = 'Account type';
                this.selectedField = accountType;
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
                // result = addableFieldList;
                if (this.selectedFieldSelection == 'Account type')
                {
                    for (let accountType in accountTypes)
                    {
                        if (accountTypes.hasOwnProperty(accountType))
                        {
                            result.push({field:accountType, label:accountType});
                        }
                    }
                }
                if (this.selectedFieldSelection == 'Field name')
                {
                    for (let field in possibleFieldNames)
                    {
                        if (possibleFieldNames.hasOwnProperty(field))
                        {
                            result.push({field:field, label:possibleFieldNames[field].label});
                        }
                    }
                }
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
        actndx: number,
        accountName: string,
        fieldSelection: string,
        field: string  // note: field contains an account type name if fieldSelection = 'Account type'
    ): void
    {
        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                /*
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
                actndx = gd.category[subcat].accounts.length;
                gd.category[subcat].accounts.push({});
                gd.category[subcat].accounts[actndx]['accountName'] = {label: 'Account Name', val:accountName, isRequired:true};
                gd.category[subcat].accounts[actndx]['accountType'] = {label: 'Account Type', val:field, isRequired:true};
                for (let field2 in accountTypes[field])
                    {
                         gd.category[subcat].accounts[actndx][field2] = accountTypes[field][field2];
                    }
            }

            if (action == 'Delete')
            {
                gd.category[subcat].accounts.splice(actndx,1);
            }
        }   // Account

        if (item == 'Field')
        {
            if (action == 'Add')
            {
                if (fieldSelection == 'Field name')
                {
                    gd.category[subcat].accounts[actndx][field] = possibleFieldNames[field];
                }
                if (fieldSelection == 'Account type')
                {
                    for (let field2 in accountTypes[field])
                    {
                         gd.category[subcat].accounts[actndx][field2] = accountTypes[field][field2];
                    }
                }
            }

            if (action == 'Delete')
            {
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
        let fieldSelection: string = this.selectedFieldSelection;
        let field: string = this.selectedField;
        let actndx: number = this.gd.getActndx(this.gd.category, subcat, accountName);

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
                if (!confirm('Do you intend to delete the subcategory:\n' + this.gd.category[subcat].label))
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
                if (this.gd.category[subcat].accounts[actndx].hasOwnProperty('isRequired') && this.gd.category[subcat].accounts[actndx].isRequired.val)
                {
                    this.messages.push(accountName + ' is required and cannot be deleted');
                    wantRefresh = false;
                }
                else
                {
                    if (!confirm('Do you intend to delete the account:\n' + this.gd.category[subcat].label + '->' + accountName))
                    {
                        wantRefresh = false;
                    }
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
                if (this.gd.category[subcat].accounts[actndx][field].hasOwnProperty('isRequired') && this.gd.category[subcat].accounts[actndx].isRequired)
                {
                    this.messages.push(this.gd.category[subcat].accounts[actndx][field].label + ' is required and cannot be deleted');
                    wantRefresh = false;
                }
                else
                {
                    if (!confirm('Do you intend to delete the field:\n' + this.gd.category[subcat].label + '->' + accountName + '->' + this.gd.category[subcat].accounts[actndx][field].label))
                    {
                        wantRefresh = false;
                    }
                }
            }
        }   // Field

        // update screen
        if (wantRefresh && !hadError)
        {
            // make changes to the screen data model behind the scenes
            Item2Management.doAction(this.gd, item, action, subcat, actndx, accountName, fieldSelection, field);

            // make changes to the application data model
            // this.component.update();

            // update screen to reflect changes in the data model
            this.gd.areAccountsVisible = this.gd.createAreAccountsVisible(this.gd.showAllAccounts);
            this.gd.areFieldsVisible = this.gd.createAreFieldsVisible(this.gd.showAllFields);
            this.gd.currentSubcategories = this.gd.getSubcategories(this.gd.category);
            this.gd.currentAccounts = this.gd.getAccounts(this.gd.category);
            this.gd.currentFields = this.gd.getFields(this.gd.category);

            /////////////////////////////////////////////////
            // updates for item management feature
            /////////////////////////////////////////////////

            // update subcategory list
            this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
            if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0].subcat;
            this.customSubcategory = '';

            // update account list
            this.accountList = this.getUpdateAccountList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
            if (Array.isArray(this.accountList) && this.accountList.length > 0) this.selectedAccount = this.accountList[0];
            this.customAccount = '';

            // update field list
            this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedAccount);
            if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0].field;
            this.customField = '';
        }
    }   // performAction

}   // class ItemManagement