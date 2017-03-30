import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
	FacebookAppID = '1436430629732183';

	constructor() { }

	ngOnInit() { }

	function doFacebookLogin()
	{
	    function getInfo(response)
	    {
	        userID = response.authResponse.userID;
	        access_token = response.authResponse.accessToken;
	        FB.api('/me', {locale: 'en_US', fields: 'email'}, function(response2)
	        {
	            email = response2.email;
	            finishLogin();
	        });
	    }   // get Info

	    loginMode = 'Facebook';
	    console.log('Facebook login');

	    // clear values on screen
	    $('#email').val('');
	    $('#val').val('');

	    FB.init(
	    {
	        appId      : FacebookAppID,
	        status     : true,
	        xfbml      : true,
	        version    : 'v2.8'
	    });

	    FB.getLoginStatus(function(response)
	    {
	        if (response.status === 'connected')
	        {
	            console.log('already logged in');
	            getInfo(response);
	        }
	        else
	        {
	            FB.login(function(response)
	            {
	                if (response.authResponse)
	                {
	                    console.log('new login');
	                    getInfo(response);
	                }
	                else
	                {
	                    console.log('Login was not successful');
	                }
	            },
	            // {scope: 'public_profile,email'}
	            // note: add auth_type: 'reauthenticate' property to force authentication even if already logged in to Facebook
	            {scope: 'public_profile,email', auth_type: 'reauthenticate'}
	            );
	        }
	    });
	}   // doFacebookLogin

	function finishLogin()
	{
	   return new Promise(function(resolve,reject)
	    {
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
	        resolve();
	    });
	}   // finishLogin

}   // class LoginComponent
