import { Component, OnInit } from '@angular/core';

import { DataModelService} from '../datamodel.service';
import { CIncomeDetails } from './incomedetails.class';

@Component({
  selector: 'app-incomedetails',
  templateUrl: './incomedetails.component.html',
  styleUrls: ['./incomedetails.component.css']
})
export class IncomedetailsComponent implements OnInit {
  // persistent data
  cIncomeDetails: CIncomeDetails;

  // transient data
  incometotal: number;

  constructor(private datamodelService: DataModelService) {
  }

  ngOnInit() {
  	this.cIncomeDetails = new CIncomeDetails(this.datamodelService.getdata('incomedetails'));
    this.calctotal();
  }

  calctotal() {
  	this.incometotal = this.cIncomeDetails.getIncomeDetailsSum();
  }

  // update data model
  update() {
  	this.datamodelService.putdata('incomedetails', this.cIncomeDetails.incomeDetails);
  }
}   // IncomedetailsComponent
