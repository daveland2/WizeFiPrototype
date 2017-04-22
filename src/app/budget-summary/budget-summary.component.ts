import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { CBudgetDetails } from '../budget-details/budget-details.class';
import { ConfigValues } from '../utilities/config-values.class';

@Component({
  selector: 'app-budget',
  templateUrl: './budget-summary.component.html',
  styleUrls: ['./budget-summary.component.css']
})
export class BudgetSummaryComponent implements OnInit {

  // transient data
  cBudgetDetails: CBudgetDetails;
  currencyCode: string;

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
    let configValues = new ConfigValues(this.dataModelService);

    this.cBudgetDetails = new CBudgetDetails(this.dataModelService.getdata('budgetDetails'));
    this.currencyCode = configValues.currencyCode();
  }

}   // class BudgetSummaryComponent
