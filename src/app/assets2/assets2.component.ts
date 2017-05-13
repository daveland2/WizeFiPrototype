import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { GenericDataManagement } from '../utilities/generic-data-management.class';
import { ItemManagement } from '../utilities/item-management.class';
import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { CAssets2 } from './assets2.class';
import { possibleAssets2 } from './assets2.data';

@Component({
  selector: 'app-assets2',
  // templateUrl: './assets2.component.html',
  templateUrl: '../utilities/generic-category.html',
  styleUrls: ['./assets2.component.css']
})
export class Assets2Component implements OnInit
{
    // persistent data
    cAssets2: CAssets2;

    // transient data
    messages: string[] = [];
    gd: GenericDataManagement;  // class to handle generic data presentation components in HTML
    im: ItemManagement; // // class to handle "Manage Items" feature
    category: any;
    categoryName: string;

    constructor(private dataModelService: DataModelService) { }

    ngOnInit()
    {
        this.cAssets2 = new CAssets2(this.dataModelService.getdata('assets2'));
        this.gd = new GenericDataManagement(this.cAssets2.assets2, possibleAssets2, this.messages);
        this.im = new ItemManagement(this.gd, this.messages);
        this.category = this.cAssets2.assets2;
        this.categoryName = 'Assets2';
    }   // ngOnInit

    verify(): void
    /*
    This routine is triggered by a blur event on a numeric data field.
    */
    {
        this.messages = [];
        let result: IVerifyResult = this.gd.verifyAllDataValues();
        if (result.hadError)
        {
            // report errors on screen
            this.messages = result.messages;
        }
    }   //  verify

    // update application data model
    update(): void
    {
        this.dataModelService.putdata('assets2', this.cAssets2.assets2);
    }

}   // class Assets2Component
