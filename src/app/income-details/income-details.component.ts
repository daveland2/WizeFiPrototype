import { Component, OnInit } from '@angular/core';

import { DataModelService} from '../data-model.service';
import { CIncomeDetails } from './income-details.class';
import { IVerifyResult } from '../utilities/validity-check.class';

@Component({
  selector: 'app-incomedetails',
  templateUrl: './income-details.component.html',
  styleUrls: ['./income-details.component.css']
})
export class IncomeDetailsComponent implements OnInit {
  // persistent data
  cIncomeDetails: CIncomeDetails;

  // transient data
  incomeTotal: number;
  messages: string[] = [];

  constructor(private dataModelService: DataModelService) {
  }

  ngOnInit() {
  	this.cIncomeDetails = new CIncomeDetails(this.dataModelService.getdata('incomeDetails'));
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
  }

  // update data model
  update() {
  	this.dataModelService.putdata('incomeDetails', this.cIncomeDetails.incomeDetails);
  }
}   // IncomedetailsComponent
