import { GenericDataManagement } from '../utilities/generic-data-management.class';
import { CValidityCheck } from './validity-check.class';

export class ItemManagement
/*
This class provides variables and routines for item management (adding and deleting items in data model).
*/
{
    selectedItem: string;
    selectedAction: string;

    subcatList: string[] = [];
    selectedSubcategory: string;
    customSubcategory: string = '';

    typeList: string[] = [];
    selectedType: string;
    customType: string = '';

    fieldList: string[] = [];
    selectedField: string;
    customField: string = '';

    constructor (private gd:GenericDataManagement, private messages:string[])
    {
        this.selectedItem = 'Subcategory';
        this.selectedAction = 'Add';

        // update subcategories list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];

        // update type list
        this.typeList = this.getUpdateTypeList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
    }   // constructor

    onItemChange(): void
    {
        // update subcategories list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];
        this.customSubcategory = '';

        // update type list
        this.typeList = this.getUpdateTypeList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];
        this.customType = '';

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
        this.customField = '';
    }   // onItemChange

    onActionChange(): void
    {
        // update subcategories list
        this.subcatList = this.getUpdateSubcategoryList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction);
        if (Array.isArray(this.subcatList) && this.subcatList.length > 0) this.selectedSubcategory = this.subcatList[0];
        this.customSubcategory = '';

        // update type list
        this.typeList = this.getUpdateTypeList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];
        this.customType = '';

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
        this.customField = '';
    }   // onActionChange

    onSubcategoryChange(): void
    {
        // update type list
        this.typeList = this.getUpdateTypeList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory);
        if (Array.isArray(this.typeList) && this.typeList.length > 0) this.selectedType = this.typeList[0];

        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
    }   // onSubcategoryChange

    onTypeChange(): void
    {
        // update field list
        this.fieldList = this.getUpdateFieldList(this.gd.category, this.gd.possibleCategory, this.selectedItem, this.selectedAction, this.selectedSubcategory, this.selectedType);
        if (Array.isArray(this.fieldList) && this.fieldList.length > 0) this.selectedField = this.fieldList[0];
    }   // onTypeChange

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

    getUpdateTypeList(currentCategory:any, possibleCategory:any, item:string, action:string, subcat:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the types drop down list in the Manage Items feature.
    */
    {
        let currentTypeList: string[] = this.gd.getTypesList(currentCategory, subcat);
        let possibleTypeList: string[] = this.gd.getTypesList(possibleCategory, subcat);
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

    getUpdateFieldList(currentCategory:any, possibleCategory:any, item:string, action:string, subcat:string, type:string): string[]
    /*
    This routine creates a list that provides the appropriate content for the fields drop down list in the Manage Items feature.
    */
    {
        let currentFieldList: string[] = this.gd.getFieldsList(currentCategory, subcat, type);
        let possibleFieldList: string[] = this.gd.getFieldsList(possibleCategory, subcat, type);
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

    public static doAction
    (
        gd: GenericDataManagement,
        item: string,
        action: string,
        subcat: string,
        type: string,
        field: string
    ): void
    {

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                gd.category[subcat] = {};
                gd.category[subcat]['label'] = subcat;
                gd.category[subcat][type] = {};
                gd.category[subcat][type]['label'] = type;
                gd.category[subcat][type]['monthlyAmount'] = 0;
                if (field != 'none') gd.category[subcat][type][field] = '';
            }

            if (action == 'Delete')
            {
                delete gd.category[subcat];
            }
        }   // Subcategory

        if (item == 'Type')
        {
            if (action == 'Add')
            {
                gd.category[subcat][type] = {};
                gd.category[subcat][type]['label'] = type;
                gd.category[subcat][type]['monthlyAmount'] = 0;
                if (field != 'none') gd.category[subcat][type][field] = '';
            }

            if (action == 'Delete')
            {
                delete gd.category[subcat][type];
            }
        }   // Type

        if (item == 'Field')
        {
            if (action == 'Add')
            {
                gd.category[subcat][type][field] = '';
            }

            if (action == 'Delete')
            {
                delete gd.category[subcat][type][field];
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
        let type: string = this.selectedType;
        let field: string = this.selectedField;

        if (item == 'Subcategory')
        {
            if (action == 'Add')
            {
                if (subcat == 'custom') subcat = this.customSubcategory
                if (type == 'custom') type = this.customType;
                if (field == 'custom') field = this.customField;

                if (CValidityCheck.checkAttributeNameValidity('subcat', subcat, this.messages)) hadError = true;
                if (CValidityCheck.checkAttributeNameValidity('type', type, this.messages)) hadError = true;
                if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;
            }

            if (action == 'Delete')
            {
                if (!confirm('Do you intend to delete the subcategory: ' + subcat))
                {
                    wantRefresh = false;
                }
            }
        }   // Subcategory

        if (item == 'Type')
        {
            if (action == 'Add')
            {
                if (type == 'custom') type = this.customType;
                if (field == 'custom') field = this.customField;

                if (CValidityCheck.checkAttributeNameValidity('type', type, this.messages)) hadError = true;
                if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;
            }

            if (action == 'Delete')
            {
                if (!confirm('Do you intend to delete the type: ' + subcat + '.' + type))
                {
                    wantRefresh = false;
                }
            }
        }   // Type

        if (item == 'Field')
        {
            if (action == 'Add')
            {
                if (field == 'none')
                {
                    wantRefresh = false;
                }
                else
                {
                    if (field == 'custom') field = this.customField;
                    if (CValidityCheck.checkAttributeNameValidity('field', field, this.messages)) hadError = true;
                }
            }

            if (action == 'Delete')
            {
                if (!confirm('Do you intend to delete the field: '+subcat+'.'+type+'.'+field))
                {
                    wantRefresh = false;
                }
            }
        }   // Field

        // update screen
        if (wantRefresh && !hadError)
        {
            // make changes to the screen data model behind the scenes
            ItemManagement.doAction(this.gd, item, action, subcat, type, field);

            // update screen to reflect changes in the data model
            this.gd.areTypesVisible = this.gd.createAreTypesVisible(this.gd.showAllTypes);
            this.gd.areFieldsVisible = this.gd.createAreFieldsVisible(this.gd.showAllFields);
            this.gd.currentSubcategories = this.gd.getSubcategories(this.gd.category);
            this.gd.currentTypes = this.gd.getTypes(this.gd.category);
            this.gd.currentFields = this.gd.getFields(this.gd.category);
        }
    }   // performAction

}   // class ItemManagement