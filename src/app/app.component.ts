import { Component } from '@angular/core';

import { DataModelService } from './data-model.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'WizwFiPrototype';

  constructor (private dataModelService: DataModelService) { }

  ngOnInit() {
  	// populate datamodel with information from persistent storage
    this.dataModelService.fetchdata();
  	console.log('AppComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('AppComponent OnDestroy');
  }

  storedata() {
  	this.dataModelService.storedata();
  }

}   //class AppComponent
