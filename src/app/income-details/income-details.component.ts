import { Component, OnInit } from '@angular/core';

import { DataModelService} from '../data-model.service';
import { CIncomeDetails } from './income-details.class';

@Component({
  selector: 'app-incomedetails',
  templateUrl: './income-details.component.html',
  styleUrls: ['./income-details.component.css']
})
export class IncomeDetailsComponent implements OnInit {
  // persistent data
  cIncomeDetails: CIncomeDetails;

  // transient data
  incomeTotal: number;

  constructor(private datamodelService: DataModelService) {
  }

  ngOnInit() {
  	this.cIncomeDetails = new CIncomeDetails(this.datamodelService.getdata('incomeDetails'));
    this.incomeTotal = this.cIncomeDetails.getIncomeDetailsSum();
  }

  calctotal() {
  	this.incomeTotal = this.cIncomeDetails.getIncomeDetailsSum();
  }

  digitOnly(event: any) {
    const pattern = /[0-9]/;
    let inputChar = String.fromCharCode(event.charCode);

    if (!pattern.test(inputChar)) {
      // invalid character, prevent input
      event.preventDefault();
    }
  }

  // update data model
  update() {
  	this.datamodelService.putdata('incomeDetails', this.cIncomeDetails.incomeDetails);
  }
}   // IncomedetailsComponent
