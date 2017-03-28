import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CBudgetDetails, IVerifyResult } from './budget-details.class';

@Component({
  selector: 'app-budgetdetails',
  templateUrl: './budget-details.component.html',
  styleUrls: ['./budget-details.component.css']
})
export class BudgetDetailsComponent implements OnInit, OnDestroy {
  // persistent data
  cBudgetDetails: CBudgetDetails;

  // transient data
  budgetTotal: number;
  messages: string[] = [];

  constructor(private datamodelService: DataModelService) { }

  ngOnInit() {
    this.cBudgetDetails = new CBudgetDetails(this.datamodelService.getdata('budgetDetails'));
    this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
    console.log("BudgetDetailsComponent onInit");
  }

  ngOnDestroy() {
    console.log("BudgetDetailsComponent onDestroy");
  }

  calcTotal() {
    this.messages = [];
    let result: IVerifyResult = this.cBudgetDetails.verifyAllDataValues();
    if (result.hadError) {
      // report errors on screen
      this.messages = result.messages;
    }
    else {
      this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
    }

  }

  // update data model
  update() {
    this.datamodelService.putdata('budgetDetails', this.cBudgetDetails.budgetDetails);
  }

}
