import { Component, OnInit } from '@angular/core';
import { ApplicationRef } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { IVerifyResult } from '../utilities/validity-check.class';
import { CAssets} from './assets.class';

declare var $: any;

@Component({
  selector: 'app-assets',
  templateUrl: './assets.component.html',
  styleUrls: ['./assets.component.css']
})
export class AssetsComponent implements OnInit
{
    // persistent data
    cAssets: CAssets;

    // transient data
	currentAssetSubcategories: string[];
	currentAssetTypes: any;

	selectedSubcatForSubcat: string;
	subcatListForSubcat: string[];

	selectedTypeForSubcat: string;
	typeListForSubcat: string[];

	selectedSubcatForType: string;
	subcatListForType: string[];

	selectedTypeForType: string;
	typeListForType: any;

	messages: string[] = [];
	subcategoryAction: string = 'Add';
	typeAction: string = 'Add';

	constructor(private ref: ApplicationRef, private dataModelService: DataModelService) { }

	ngOnInit()
	{
	    this.cAssets = new CAssets(this.dataModelService.getdata('assets'));

		this.currentAssetSubcategories = this.cAssets.getAssetSubcategories(this.cAssets.assets);
		this.currentAssetTypes = this.cAssets.getAssetTypes(this.cAssets.assets);

		this.subcatListForSubcat = this.cAssets.getSubcatListForSubcat('Add');
    	this.selectedSubcatForSubcat = this.subcatListForSubcat[0];

		this.typeListForSubcat = this.cAssets.getTypeListForSubcat(this.selectedSubcatForSubcat, 'Add');
		this.selectedTypeForSubcat = this.typeListForSubcat[0];

		this.subcatListForType = this.cAssets.getSubcatListForType('Add');
		this.typeListForType = this.cAssets.getTypeListForType(this.selectedSubcatForType, 'Add');
	}   // ngOnInit

	onSubcategoryActionChange()
	{
		let action = $('.subcategory:checked').val();
		this.subcategoryAction = action;

    	this.subcatListForSubcat = this.cAssets.getSubcatListForSubcat(action);
    	this.selectedSubcatForSubcat = this.subcatListForSubcat[0];

		this.typeListForSubcat = this.cAssets.getTypeListForSubcat(this.selectedSubcatForSubcat, this.subcategoryAction);
    	this.selectedTypeForSubcat = this.typeListForSubcat[0];
	}   // onSubcategoryActionChange

	onSubcatForSubcatChange()
	{
		this.typeListForSubcat = this.cAssets.getTypeListForSubcat(this.selectedSubcatForSubcat, this.subcategoryAction);
		if (this.typeListForSubcat.length > 0) this.selectedTypeForSubcat = this.typeListForSubcat[0];
	}   // onSubcatForSubcatChange

	onTypeForSubcatChange()
	{

	}   // onTypeForSubcatChange

	onTypeActionChange()
	{
		this.typeAction = $('.type:checked').val();
	}   // onTypeActionChange

	verify()
	{
		this.messages = [];
		let result: IVerifyResult = this.cAssets.verifyAllDataValues();
		if (result.hadError) {
			// report errors on screen
			this.messages = result.messages;
			this.ref.tick();  // force change detection so screen will be updated
		}
	} //  verify

	// update data model
	update()
	{
		this.dataModelService.putdata('assets', this.cAssets.assets);
	}

}   // class AssetsComponent
