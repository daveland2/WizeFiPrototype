import { Component } from '@angular/core';
import { Router } from '@angular/router';

import { DataModelService } from './data-model/data-model.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'WizeFiPrototype';

  constructor (private router: Router, private dataModelService: DataModelService) { }

  ngOnInit() { }

  ngOnDestroy() { }

}   //class AppComponent
