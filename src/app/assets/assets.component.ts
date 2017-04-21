import { Component, OnInit } from '@angular/core';
import { ApplicationRef } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { IVerifyResult } from '../utilities/validity-check.class';
import { CAssets} from './assets.class';

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
	assetSubcategories: string[];
	assetTypes: any;
	messages: string[] = [];

	constructor(private ref: ApplicationRef, private dataModelService: DataModelService) { }

	ngOnInit()
	{
	    this.cAssets = new CAssets(this.dataModelService.getdata('assets'));
		this.assetSubcategories = this.getAssetSubcategories();
		this.assetTypes = this.getAssetTypes();
	}   // ngOnInit

	getAssetSubcategories()
	{
		let result = [];
	    for (var subcat of Object.keys(this.cAssets.assets))
	    {
			result.push(subcat);
    	}
		return result;
	}   // getAssetSubcategories

	getAssetTypes()
	{
		let result = {};
		for (var subcat of Object.keys(this.cAssets.assets))
		{
	        result[subcat] = [];
		    for (var type of Object.keys(this.cAssets.assets[subcat]))
		    {
				result[subcat].push(type);
			}
		}
		return result;
	}   // getAssetTypes

	verify()
	{
		this.messages = [];
		let result: IVerifyResult = this.cAssets.verifyAllDataValues();
		if (result.hadError) {
			// report errors on screen
			this.messages = result.messages;
		}
		else
		{
			// update calculated values on screen
			// this.budgetTotal = this.cAssets.getAssetsSum();
		}
		this.ref.tick();  // force change detection so screen will be updated
	} //  verify

	// update data model
	update()
	{
		this.dataModelService.putdata('assets', this.cAssets.assets);
	}

}   // class AssetsComponent
