import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CIncomeDetails } from '../income-details/income-details.class';

@Component({
  selector: 'app-income',
  templateUrl: './income.component.html',
  styleUrls: ['./income.component.css']
})
export class IncomeComponent implements OnInit, OnDestroy {

  // transient data
  cIncomeDetails: CIncomeDetails;
  incomeTotal: number;

  constructor(private datamodelService: DataModelService) { }

  ngOnInit() {
    this.cIncomeDetails = new CIncomeDetails(this.datamodelService.getdata('incomeDetails'));
    this.incomeTotal = this.cIncomeDetails.getIncomeDetailsSum();
  	console.log('IncomeComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('IncomeComponent OnDestroy');
  }

}
