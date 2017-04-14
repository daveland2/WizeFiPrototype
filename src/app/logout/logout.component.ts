import { Component, OnInit } from '@angular/core';
import {Location} from '@angular/common';
import {Router} from '@angular/router';

import { DataModelService } from '../data-model/data-model.service';

declare const FB: any;

@Component({
  selector: 'app-logout',
  templateUrl: './logout.component.html',
  styleUrls: ['./logout.component.css']
})
export class LogoutComponent implements OnInit {

  messages: string[] = [];

	constructor(private dataModelService: DataModelService, private location: Location, private router: Router) { }

	ngOnInit() { }

  logout = (): void =>
	// logout(dataModelService)
  {
      this.dataModelService.dataModel.global.isLoggedIn = false;
    	FB.logout((response) =>
      {
		      console.log('Facebook logout');  //%//
		  });
	} // logout

  saveAndLogout = ():void =>
  {
      let handleLogout = (): void =>
      {
        this.logout();
        this.router.navigateByUrl('/login');
      }

      let handleError = (err: any): void =>
      {
        this.messages.push('Error in attempting to retrieve user data');
        console.log(err);
      }

    	this.dataModelService.storedata()
      .then(handleLogout)
      .catch(handleError)
  } // saveAndLogout

  ignoreAndLogout = ():void =>
  {
    	this.logout();
      this.router.navigateByUrl('/login');
  }

  save = ():void =>
  {

      let goback = (): void =>
      {
          this.location.back();
      }

      let handleError = (err: any): void =>
      {
          this.messages.push('Error in attempting to retrieve user data');
          console.log(err);
      }

      this.dataModelService.storedata()
      .then(goback)
      .catch(handleError)
  } // save

	cancel = ():void =>
  {
		  this.location.back();
	}
}
