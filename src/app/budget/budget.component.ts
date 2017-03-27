import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../datamodel.service';

// kludge for now  //*//
interface Ibudgetdetails {
  housing: number,
  food: number
}

@Component({
  selector: 'app-budget',
  templateUrl: './budget.component.html',
  styleUrls: ['./budget.component.css']
})
export class BudgetComponent implements OnInit, OnDestroy {

  // transient data
  budgetdetails: Ibudgetdetails;
  budgettotal: number;

  constructor(private datamodelService: DataModelService) {

  }

  ngOnInit() {
    this.budgetdetails = this.datamodelService.getdata('budgetdetails');
    this.budgettotal = this.datamodelService.getBudgetDetailsSum(this.budgetdetails);
  	console.log('BudgetComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('BudgetComponent OnDestroy');
  }

}   // class BudgetComponent
