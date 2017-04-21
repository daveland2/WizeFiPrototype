import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { CIncomeDetails } from '../income-details/income-details.class';
import { ConfigValues } from '../utilities/config-values.class';

@Component({
  selector: 'app-income',
  templateUrl: './income.component.html',
  styleUrls: ['./income.component.css']
})
export class IncomeComponent implements OnInit {

  // transient data
  cIncomeDetails: CIncomeDetails;
  currencyCode: string;

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
    let configValues = new ConfigValues(this.dataModelService);

    this.cIncomeDetails = new CIncomeDetails(this.dataModelService.getdata('incomeDetails'));
    this.currencyCode = configValues.currencyCode();
  }

}
