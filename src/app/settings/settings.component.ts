import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { CSettings} from './settings.class';
import { IVerifyResult } from '../utilities/validity-check.class';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.css']
})
export class SettingsComponent implements OnInit {
  // persistent data
  cSettings: CSettings;

  // transient data
  messages: string[] = [];

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
  	this.cSettings = new CSettings(this.dataModelService.getdata('settings'));
  }


 verify() {
    this.messages = [];
    let result: IVerifyResult = this.cSettings.verifyAllDataValues();
    if (result.hadError) {
      // report errors on screen
      this.messages = result.messages;
    }
  }

  // update data model
  update() {
    this.dataModelService.putdata('settings', this.cSettings.settings);
  }

}
