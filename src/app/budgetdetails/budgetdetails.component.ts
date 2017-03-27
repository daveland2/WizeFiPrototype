import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService, Ibudgetdetails } from '../datamodel.service';

@Component({
  selector: 'app-budgetdetails',
  templateUrl: './budgetdetails.component.html',
  styleUrls: ['./budgetdetails.component.css']
})
export class BudgetdetailsComponent implements OnInit, OnDestroy {
  // persistent data
  budgetdetails: Ibudgetdetails;

  // transient data
  budgettotal: number;

  constructor(private datamodelService: DataModelService) {
  }

  ngOnInit() {
  	this.budgetdetails = this.datamodelService.getdata('budgetdetails');
    this.calctotal();
  	console.log('BudgetdetailsComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('BudgetdetailsComponent OnDestroy');
  }

  getBudgetDetailsSum() {
    return this.datamodelService.getBudgetDetailsSum(this.budgetdetails);
  }

  calctotal() {
  	this.budgettotal = this.datamodelService.getBudgetDetailsSum(this.budgetdetails);
  }

  // update data model
  update() {
  	this.datamodelService.putdata('budgetdetails', this.budgetdetails);
  }

}
