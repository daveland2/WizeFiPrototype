import { Component, OnInit } from '@angular/core';
import { ApplicationRef } from '@angular/core';

import { DataModelService} from '../data-model.service';
import { CIncomeDetails } from './income-details.class';
import { IVerifyResult } from '../utilities/validity-check.class';
import { ConfigValues } from '../utilities/config-values.class';

@Component({
  selector: 'app-incomedetails',
  templateUrl: './income-details.component.html',
  styleUrls: ['./income-details.component.css']
})
export class IncomeDetailsComponent implements OnInit {
  // persistent data
  cIncomeDetails: CIncomeDetails;

  // transient data
  currencyCode: string;
  incomeTotal: number;
  messages: string[] = [];

  constructor(private ref: ApplicationRef, private dataModelService: DataModelService) {
  }

  ngOnInit() {
    let configValues = new ConfigValues(this.dataModelService);

  	this.cIncomeDetails = new CIncomeDetails(this.dataModelService.getdata('incomeDetails'));
    this.currencyCode = configValues.currencyCode();
    this.incomeTotal = this.cIncomeDetails.getIncomeDetailsSum();
  }

  verify() {
    this.messages = [];
    let result: IVerifyResult = this.cIncomeDetails.verifyAllDataValues();
    if (result.hadError) {
      // report errors on screen
      this.messages = result.messages;
    }
    else {
      // update calculated values on screen
      this.incomeTotal = this.cIncomeDetails.getIncomeDetailsSum();
    }
    this.ref.tick();  // force change detection so screen will be updated
  } // verify

  // update data model
  update() {
  	this.dataModelService.putdata('incomeDetails', this.cIncomeDetails.incomeDetails);
  }
}   // IncomedetailsComponent
