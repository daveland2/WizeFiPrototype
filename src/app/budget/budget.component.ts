import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CBudgetDetails } from '../budget-details/budget-details.class';
import { ConfigValues } from '../utilities/config-values.class';

@Component({
  selector: 'app-budget',
  templateUrl: './budget.component.html',
  styleUrls: ['./budget.component.css']
})
export class BudgetComponent implements OnInit, OnDestroy {

  // transient data
  cBudgetDetails: CBudgetDetails;
  currencyCode: string;
  budgetTotal: number;

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
    let configValues = new ConfigValues(this.dataModelService);

    this.cBudgetDetails = new CBudgetDetails(this.dataModelService.getdata('budgetDetails'));
    this.currencyCode = configValues.currencyCode();
    this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
  	console.log('BudgetComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('BudgetComponent OnDestroy');
  }

}   // class BudgetComponent
