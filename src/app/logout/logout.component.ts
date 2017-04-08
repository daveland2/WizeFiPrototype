import { Component, OnInit } from '@angular/core';
import {Location} from '@angular/common';
import {Router} from '@angular/router';

import { DataModelService } from '../data-model.service';
import { ManageMessages } from '../utilities/manage-messages.class';

declare const FB: any;

@Component({
  selector: 'app-logout',
  templateUrl: './logout.component.html',
  styleUrls: ['./logout.component.css']
})
export class LogoutComponent implements OnInit {

  messages: string[] = [];

	constructor(
    private dataModelService: DataModelService,
    private location: Location,
    private router: Router,
    private manageMessages: ManageMessages
  ) { }

	ngOnInit() { }

  // note: in order to deal with issues of the "this" qualifier, need to pass in argument to this function
	logout(dataModelService) {
      dataModelService.dataModel.global.isLoggedIn = false;
    	FB.logout(function(response) {
		  console.log('Facebook logout');  //%//
		});
	} // logout

  saveAndLogout() {
    // kludge to get information into scope of nested function
    let logout = this.logout;
    let router = this.router;
    let dataModelService = this.dataModelService;
    let messages = this.messages;
    let manageMessages = this.manageMessages;

    function handleLogout()
    {
      logout(dataModelService);
      router.navigateByUrl('/login');
    }

    function handleError(err)
    {
      manageMessages.update(messages,'Error in attempting to retrieve user data');
      console.log(err);
    }

  	this.dataModelService.storedata()
    .then(handleLogout)
    .catch(handleError)
  } // saveAndLogout

  ignoreAndLogout() {
  	this.logout(this.dataModelService);
    this.router.navigateByUrl('/login');
  }

  save() {
    // kludge to get information into scope of nested function
    let logout = this.logout;
    let router = this.router;
    let dataModelService = this.dataModelService;
    let messages = this.messages;
    let manageMessages = this.manageMessages;
    let location = this.location;

    function goback() {
      location.back();
    }

    function handleError(err)
    {
      manageMessages.update(messages,'Error in attempting to retrieve user data');
      console.log(err);
    }

    this.dataModelService.storedata()
    .then(goback)
    .catch(handleError)
  }

	cancel() {
		this.location.back();
	}
}
