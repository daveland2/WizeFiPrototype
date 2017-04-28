import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { GenericDataManagement } from '../utilities/generic-data-management.class';
import { ItemManagement } from '../utilities/item-management.class';
import { CValidityCheck, IVerifyResult } from '../utilities/validity-check.class';
import { CAssets } from './assets.class';
import { possibleAssets } from './assets.data';

@Component({
  selector: 'app-assets',
  // templateUrl: './assets.component.html',
  templateUrl: '../utilities/generic-category.html',
  styleUrls: ['./assets.component.css']
})
export class AssetsComponent implements OnInit
{
    // persistent data
    cAssets: CAssets;

    // transient data
    messages: string[] = [];
    gd: GenericDataManagement;  // class to handle generic data presentation components in HTML
    im: ItemManagement; // // class to handle "Manage Items" feature
    category: any;
    categoryName: string;

    constructor(private dataModelService: DataModelService) { }

    ngOnInit()
    {
        this.cAssets = new CAssets(this.dataModelService.getdata('assets'));
        this.gd = new GenericDataManagement(this.cAssets.assets, possibleAssets, this.messages);
        this.im = new ItemManagement(this.gd, this.messages);
        this.category = this.cAssets.assets;
        this.categoryName = 'Assets';
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
        this.dataModelService.putdata('assets', this.cAssets.assets);
    }

}   // class AssetsComponent
