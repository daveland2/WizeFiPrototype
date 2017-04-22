import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { DataModelService } from '../data-model/data-model.service';

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

	constructor(private router: Router, private dataModelService: DataModelService) { }

	ngOnInit() { }

   	login = ():void =>
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
	                	this.messages.push('Login was not successful');
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

    getInfo = (response:IResponse):void =>
    {
        this.dataModelService.dataModel.global.userID = response.authResponse.userID;
        this.dataModelService.dataModel.global.access_token = response.authResponse.accessToken;
        FB.api('/me', {locale: 'en_US', fields: 'email'}, (response2) =>
        {
            this.dataModelService.dataModel.global.email = response2.email;
            this.finishLogin();
        });
    }   // get Info

	finishLogin = ():void =>
	{
		// define function is this manner to get "static" version of "this"
		let wrapup = ():void =>
		{
			// show login results
			console.log("userID: " + this.dataModelService.dataModel.global.userID);                      //%//
			console.log("email: " + this.dataModelService.dataModel.global.email);                        //%//
			console.log('access_token: ' + this.dataModelService.dataModel.global.access_token);          //%//
			console.log("lambda client ID: " + this.dataModelService.dataModel.global.lambda._clientId);  //%//
			console.log("isNewUser: " + this.dataModelService.dataModel.global.isNewUser);                //%//
			console.log("Login completed");                                         //%//
			this.dataModelService.dataModel.global.isLoggedIn = true;
			if (this.dataModelService.dataModel.global.isNewUser) this.router.navigateByUrl('/profile');
			else this.router.navigateByUrl('/budget-summary');
		}

		let handleError = (err: any):void =>
		{
			this.messages.push('Error in attempting to retrieve user data');
			console.log('Error in attempting to retrieve user data:');  //%//
			console.log(err);  //%//
		}

		// establish AWS object
		let logins = {'graph.facebook.com': this.dataModelService.dataModel.global.access_token};
		AWS.config.update({region: 'us-west-2'});
		AWS.config.credentials = new AWS.CognitoIdentityCredentials(
		{
		    IdentityPoolId: 'us-west-2:59b6f6d7-03c4-47aa-8ac8-3e70c1e04a03',
		    Logins: logins
		});

		// establish lambda object for invoking Lambda functions
		this.dataModelService.dataModel.global.lambda = new AWS.Lambda();

		// retrieve persistent data
		this.dataModelService.fetchdata()
		.then(wrapup)
		.catch(handleError);
	}   // finishLogin

}   // class LoginComponent
