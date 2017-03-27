import { Component, OnInit } from '@angular/core';

import { DataModelService, Iincomedetails } from '../datamodel.service';

@Component({
  selector: 'app-incomedetails',
  templateUrl: './incomedetails.component.html',
  styleUrls: ['./incomedetails.component.css']
})
export class IncomedetailsComponent implements OnInit {
  // persistent data
  incomedetails: Iincomedetails;

  // transient data
  incometotal: number;

  constructor(private datamodelService: DataModelService) {
  }

  ngOnInit() {
  	this.incomedetails = this.datamodelService.getdata('incomedetails');
    this.calctotal();
  }

  calctotal() {
  	this.incometotal = this.datamodelService.getIncomeDetailsSum(this.incomedetails);
  }

  // update data model
  update() {
  	this.datamodelService.putdata('incomedetails', this.incomedetails);
  }
}   // IncomedetailsComponent
