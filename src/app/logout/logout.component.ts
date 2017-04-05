import { Component, OnInit } from '@angular/core';
import {Location} from '@angular/common';
import {Router} from '@angular/router';

import { DataModelService } from '../data-model.service';

declare const FB: any;

@Component({
  selector: 'app-logout',
  templateUrl: './logout.component.html',
  styleUrls: ['./logout.component.css']
})
export class LogoutComponent implements OnInit {

	constructor(private dataModelService: DataModelService, private location: Location, private router: Router) { }

	ngOnInit() { }

	logout() {
		FB.logout(function(response) {
		    console.log('Facebook logout');  //%//
		});
	}

  saveAndLogout() {
    // kludge to get information into scope of nested function
    let logout = this.logout;
    let router = this.router;

    function handleLogout()
    {
      logout();
      router.navigateByUrl('/login');
    }

    function handleError(err)
    {
      console.log(err);
    }

  	this.dataModelService.storedata()
    .then(handleLogout)
    .catch(handleError)
  }

  ignoreAndLogout() {
  	this.logout();
    this.router.navigateByUrl('/login');
  }

	cancelLogout() {
		this.location.back();
	}
}
