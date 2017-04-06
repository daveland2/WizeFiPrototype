import { Component, OnInit, OnDestroy } from '@angular/core';
import { ApplicationRef } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CBudgetDetails} from './budget-details.class';
import { IVerifyResult } from '../utilities/validity-check.class';
import { ConfigValues } from '../utilities/config-values.class';

@Component({
  selector: 'app-budgetdetails',
  templateUrl: './budget-details.component.html',
  styleUrls: ['./budget-details.component.css']
})
export class BudgetDetailsComponent implements OnInit, OnDestroy {
  // persistent data
  cBudgetDetails: CBudgetDetails;

  // transient data
  currencyCode: string;
  budgetTotal: number;
  messages: string[] = [];

  constructor(private ref: ApplicationRef, private dataModelService: DataModelService) { }

  ngOnInit() {
    let configValues = new ConfigValues(this.dataModelService);

    this.cBudgetDetails = new CBudgetDetails(this.dataModelService.getdata('budgetDetails'));
    this.currencyCode = configValues.currencyCode();
    this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
    console.log("BudgetDetailsComponent onInit");
  } // ngOnInit

  ngOnDestroy() {
    console.log("BudgetDetailsComponent onDestroy");
  }

  verify() {
    this.messages = [];
    let result: IVerifyResult = this.cBudgetDetails.verifyAllDataValues();
    if (result.hadError) {
      // report errors on screen
      this.messages = result.messages;
    }
    else {
      // update calculated values on screen
      this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
    }
    this.ref.tick();  // force change detection so screen will be updated
  } //  verify

  // update data model
  update() {
    this.dataModelService.putdata('budgetDetails', this.cBudgetDetails.budgetDetails);
  }

}
