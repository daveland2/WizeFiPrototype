import { Component } from '@angular/core';

import { DataModelService } from './datamodel.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'WizwFiPrototype';

  constructor (private datamodelService: DataModelService) { }

  ngOnInit() {
  	// populate datamodel with information from persistent storage
    this.datamodelService.fetchdata();
  	console.log('AppComponent OnInit');
  }

  ngOnDestroy() {
  	console.log('AppComponent OnDestroy');
  }

  storedata() {
  	this.datamodelService.storedata();
  }

}   //class AppComponent
