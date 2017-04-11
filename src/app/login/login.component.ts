import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { DataModelService } from '../data-model/data-model.service';
import { ManageMessages } from '../utilities/manage-messages.class';

declare const FB: any;
declare const AWS: any;

interface IResponse {
    authResponse: {
    	accessToken: string,
    	expiresIn: number,
    	signedRequest: string,
    	userID: string
    },
    status: string
}

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
	FacebookAppID: string = '1862692110681013';  // WizeFiPrototype;

	// transient data
	messages: string[] = [];

	constructor(private router: Router, private dataModelService: DataModelService, private manageMessages: ManageMessages) { }

	ngOnInit() { }

   	login()
	{
		// initialize
	    console.log('Login started');  //%//
	    this.messages = [];

	    FB.init(
	    {
	        appId:   this.FacebookAppID,
	        status:  true,
	        xfbml:   true,
	        version: 'v2.8'
	    });

	    FB.getLoginStatus((response:IResponse) =>
	    {
	        if (response.status === 'connected')
	        {
	            console.log('already logged in');  //%//
	            this.getInfo(response);
	        }
	        else
	        {
	            FB.login((response) =>
	            {
	                if (response.authResponse)
	                {
	                    console.log('new login');  //%//
	                    this.getInfo(response);
	                }
	                else
	                {
	                	this.manageMessages.update(this.messages,'Login was not successful');
	                    console.log('Login was not successful');  //%//
	                }
	            },
	            {scope: 'public_profile,email'}
	            // note: add auth_type: 'reauthenticate' property to force authentication even if already logged in to Facebook
	            // {scope: 'public_profile,email', auth_type: 'reauthenticate'}
	            );
	        }
	    });
	}   // login

    getInfo(response: IResponse)
    {
        this.dataModelService.dataModel.global.userID = response.authResponse.userID;
        this.dataModelService.dataModel.global.access_token = response.authResponse.accessToken;
        FB.api('/me', {locale: 'en_US', fields: 'email'}, (response2) =>
        {
            this.dataModelService.dataModel.global.email = response2.email;
            this.finishLogin();
        });
    }   // get Info

	finishLogin()
	{
		function wrapup()
		{
			// show login results
			console.log("userID: " + dataModel.global.userID);                      //%//
			console.log("email: " + dataModel.global.email);                        //%//
			console.log('access_token: ' + dataModel.global.access_token);          //%//
			console.log("lambda client ID: " + dataModel.global.lambda._clientId);  //%//
			console.log("isNewUser: " + dataModel.global.isNewUser);                //%//
			console.log("Login completed");                                         //%//
			dataModel.global.isLoggedIn = true;
			if (dataModel.global.isNewUser) router.navigateByUrl('/profile');
			else router.navigateByUrl('/budget');
		}

		function handleError(err)
		{
			manageMessages.update(messages,'Error in attempting to retrieve user data');
			console.log('Error in attempting to retrieve user data:');  //%//
			console.log(err);  //%//
		}

		// kludge to get information into scope of nested function
		let dataModel = this.dataModelService.dataModel;
		let router = this.router;
		let messages = this.messages;
		let manageMessages = this.manageMessages;

		// establish lambda object for invoking Lambda functions
		let logins = {'graph.facebook.com': this.dataModelService.dataModel.global.access_token};
		AWS.config.update({region: 'us-west-2'});
		AWS.config.credentials = new AWS.CognitoIdentityCredentials(
		{
		    IdentityPoolId: 'us-west-2:59b6f6d7-03c4-47aa-8ac8-3e70c1e04a03',
		    Logins: logins
		});
		this.dataModelService.dataModel.global.lambda = new AWS.Lambda();

		// retrieve persistent data
		this.dataModelService.fetchdata()
		.then(wrapup)
		.catch(handleError);
	}   // finishLogin

}   // class LoginComponent
