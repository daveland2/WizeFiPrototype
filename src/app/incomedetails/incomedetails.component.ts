import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../datamodel.service';

// the following interface definition is a kludge to get around Iincomedetails name not found problem
interface Iincomedetails {
	salary: number,
	interest: number
}

@Component({
  selector: 'app-incomedetails',
  templateUrl: './incomedetails.component.html',
  styleUrls: ['./incomedetails.component.css']
})
export class IncomedetailsComponent implements OnInit {
  incomedetails: Iincomedetails;
  incometotal: number;

  constructor(private datamodelService: DataModelService) {
  }

  ngOnInit() {
  	this.incomedetails = this.datamodelService.getdata('incomedetails');
    this.calctotal();
  }

  calctotal() {
  	// note kludge of *1 to convert string to number (otherwise + is string concatenation)
  	this.incometotal = this.incomedetails.salary*1 + this.incomedetails.interest*1;
  }

  // update data model
  update() {
  	this.datamodelService.putdata('incomedetails', this.incomedetails);
  }
}   // IncomedetailsComponent
