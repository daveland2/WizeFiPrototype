import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CBudgetDetails } from '../budget-details/budget-details.class';

@Component({
  selector: 'app-budget',
  templateUrl: './budget.component.html',
  styleUrls: ['./budget.component.css']
})
export class BudgetComponent implements OnInit, OnDestroy {

  // transient data
  cBudgetDetails: CBudgetDetails;
  budgetTotal: number;

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
    this.cBudgetDetails = new CBudgetDetails(this.dataModelService.getdata('budgetDetails'));
    this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
  	console.log('BudgetComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('BudgetComponent OnDestroy');
  }

}   // class BudgetComponent
