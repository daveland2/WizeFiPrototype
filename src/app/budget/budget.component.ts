import { Component, OnInit, OnDestroy } from '@angular/core';

@Component({
  selector: 'app-budget',
  templateUrl: './budget.component.html',
  styleUrls: ['./budget.component.css']
})
export class BudgetComponent implements OnInit, OnDestroy {

  constructor() { }

  ngOnInit() {
  	console.log('BudgetComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('BudgetComponent OnDestroy');
  }

}
