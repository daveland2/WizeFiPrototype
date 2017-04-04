import { Component } from '@angular/core';

import { DataModelService } from './data-model.service';
import {Router} from '@angular/router';

import { NumberSeparators } from './utilities/number-separators.class';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'WizwFiPrototype';

  constructor (private router: Router, private dataModelService: DataModelService) { }

  ngOnInit() { }

  ngOnDestroy() { }

  storedata() {
  	this.dataModelService.storedata();
  }

}   //class AppComponent
