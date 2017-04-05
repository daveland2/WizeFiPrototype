import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CIncomeDetails } from '../income-details/income-details.class';
import { ConfigValues } from '../utilities/config-values.class';

@Component({
  selector: 'app-income',
  templateUrl: './income.component.html',
  styleUrls: ['./income.component.css']
})
export class IncomeComponent implements OnInit, OnDestroy {

  // transient data
  cIncomeDetails: CIncomeDetails;
  currencyCode: string;
  incomeTotal: number;

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
    let configValues = new ConfigValues(this.dataModelService);

    this.cIncomeDetails = new CIncomeDetails(this.dataModelService.getdata('incomeDetails'));
    this.currencyCode = configValues.currencyCode();
    this.incomeTotal = this.cIncomeDetails.getIncomeDetailsSum();
  	console.log('IncomeComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('IncomeComponent OnDestroy');
  }

}
