import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../datamodel.service';

// the following interface definition is a kludge to get around Ibudgetdetails name not found problem
interface Ibudgetdetails {
	housing: number,
	food: number
}

@Component({
  selector: 'app-budgetdetails',
  templateUrl: './budgetdetails.component.html',
  styleUrls: ['./budgetdetails.component.css']
})
export class BudgetdetailsComponent implements OnInit, OnDestroy {
  budgetdetails: Ibudgetdetails;
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

  calctotal() {
  	// note kludge of *1 to convert string to number (otherwise + is string concatenation)
  	this.budgettotal = this.budgetdetails.housing*1 + this.budgetdetails.food*1;
  }

  // update data model
  update() {
  	this.datamodelService.putdata('budgetdetails', this.budgetdetails);
  }

}
