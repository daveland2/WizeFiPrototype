import { Component, OnInit } from '@angular/core';

declare const FB: any;

/*
let userID: string;
let access_token: string;
let email: string;
*/

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
	// FacebookAppID: string = '1436430629732183';  // processDataApp
	FacebookAppID: string = '1862692110681013';  // WizeFiPrototypeApp
	userID: string;
	access_token: string;
	email: string;

	constructor() { }

	ngOnInit() { }

   	doFacebookLogin()
	{
	    console.log('Facebook login');

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
	            console.log('already logged in');
	            this.getInfo(response);
	        }
	        else
	        {
	            FB.login((response) =>
	            {
	                if (response.authResponse)
	                {
	                    console.log('new login');
	                    this.getInfo(response);
	                }
	                else
	                {
	                    console.log('Login was not successful');
	                }
	            },
	            {scope: 'public_profile,email'}
	            // note: add auth_type: 'reauthenticate' property to force authentication even if already logged in to Facebook
	            // {scope: 'public_profile,email', auth_type: 'reauthenticate'}
	            );
	        }
	    });
	}   // doFacebookLogin

    getInfo(response: IResponse)
    {
        this.userID = response.authResponse.userID;
        this.access_token = response.authResponse.accessToken;
        FB.api('/me', {locale: 'en_US', fields: 'email'}, (response2) =>
        {
            this.email = response2.email;
            this.finishLogin();
        });
    }   // get Info

	finishLogin()
	{
	   return new Promise((resolve,reject) =>
	    {
	        console.log("userID: " + this.userID);
	        console.log("email: " + this.email);
	        console.log('access_token: ' + this.access_token);

            /*
	        let logins;

	        // set logins info
	        logins = {'graph.facebook.com': access_token};

	        // establish lambda object for invoking Lambda functions
	        AWS.config.update({region: 'us-west-2'});
	        AWS.config.credentials = new AWS.CognitoIdentityCredentials(
	        {
	            IdentityPoolId: 'us-west-2:a754ae55-d81e-4b0a-a697-17c5e32ee052',
	            Logins: logins
	        });
	        lambda = new AWS.Lambda();
	        console.log("Login completed")
	        $("#loggedin").show();
	        */
	        console.log("finished login");
	        resolve();
	    });
	}   // finishLogin

}   // class LoginComponent
