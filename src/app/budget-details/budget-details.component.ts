import { Component, OnInit, OnDestroy } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CBudgetDetails } from './budget-details.class';

@Component({
  selector: 'app-budgetdetails',
  templateUrl: './budget-details.component.html',
  styleUrls: ['./budget-details.component.css']
})
export class BudgetdetailsComponent implements OnInit {
  // persistent data
  cBudgetDetails: CBudgetDetails;

  // transient data
  budgetTotal: number;

  constructor(private datamodelService: DataModelService) { }

  ngOnInit() {
    this.cBudgetDetails = new CBudgetDetails(this.datamodelService.getdata('budgetDetails'));
    this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
  }

  calcTotal() {
    this.budgetTotal = this.cBudgetDetails.getBudgetDetailsSum();
  }

  // update data model
  update() {
    this.datamodelService.putdata('budgetDetails', this.cBudgetDetails.budgetDetails);
  }

}
