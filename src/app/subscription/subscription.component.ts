import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';

@Component({
  selector: 'app-subscription',
  templateUrl: './subscription.component.html',
  styleUrls: ['./subscription.component.css']
})
export class SubscriptionComponent {

  cardNumber: string = '4242424242424242';
  expiryMonth: string = '05';
  expiryYear: string = '2018';
  cvc: string = '123';
  messages: string[] = [];

  private email;
  private stripeCustomerID;

  constructor(private dataModelService: DataModelService)
  {
      // initialize (code to simplify future references)
      this.email = this.dataModelService.dataModel.global.email;
      this.stripeCustomerID = this.dataModelService.dataModel.persistent.header.stripeCustomerID;

  }   // constructor

  establishSubscription = ():void =>
  {

      let checkUser = (): Promise<any> =>
      {
          return new Promise((resolve,reject) =>
          {
              if (this.stripeCustomerID != '') reject('Current user ' + this.email + ' already has a subscription');
              else resolve();
          });
      }   // checkUser

      let confirmAction = (): Promise<any> =>
      {
          return new Promise((resolve,reject) =>
          {
              let result = confirm(
`Do you wish to perform all of the following actions:\n
- Create WizeFi user account\n
- Create a Stripe customer account\n
- Store credit card information in account\n
- Add subscription to customer account\n
- Pay $8.00 per month, starting today`
              );
              if (result) resolve();
              else reject('Subscription action declined');
          });
      }   // confirmAction

      let getToken = (): Promise<any> =>
      {
          return new Promise((resolve,reject) =>
          {
              (<any>window).Stripe.card.createToken
              (
                  {
                      number: this.cardNumber,
                      exp_month: this.expiryMonth,
                      exp_year: this.expiryYear,
                      cvc: this.cvc
                  },
                  (status: number, response: any) =>
                  {
                      if (status === 200)
                      {
                          resolve(response.id);
                      }
                      else
                      {
                          reject(response.error.message);
                      }
                  }
              );
          });
      }   // getToken

      let addUserAndSubscribe = (sourceToken): Promise<any> =>
      {
        return new Promise((resolve,reject) =>
          {
            // set params to guide function invocation
            let payload_in =
            {
                email: this.email,
                plan: "WizeFiPrototypePlan",
                sourceToken: sourceToken
            };
            let params =
            {
                FunctionName: 'establishSubscription',
                Payload: JSON.stringify(payload_in)
            };

            // invoke Lambda function to process data
            this.dataModelService.dataModel.global.lambda.invoke(params, (err,data) =>
            {
                if (err)
                {
                    reject(JSON.stringify(err));
                }
                else
                {
                    if (!data.hasOwnProperty('Payload'))
                    {
                        reject("Data does not contain Payload attribute");
                    }
                    else
                    {
                        let payload_out = JSON.parse(data.Payload);
                        if (payload_out.hasOwnProperty('errorMessage'))
                        {
                            //reject("errorMessage: " + payload.errorMessage);
                            reject('lambda had error')
                        }
                        else
                        {
                            resolve(payload_out);
                        }
                    }
                }
            }); // lambda invoke
        });   // return new Promise
      }   // addUserAndSubscribe

      let finish = (payload_out):void =>
      {
          this.dataModelService.dataModel.persistent.header.stripeCustomerID = payload_out.stripeCustomerID;
          this.dataModelService.dataModel.persistent.header.stripeSubscriptionID = payload_out.stripeSubscriptionID;
          this.dataModelService.storedata();  // create WizeFi user account
          console.log('Subscription has been registered');  //%//
          this.messages.push('Subscription has been registered');
      }   // finish

      let handleError = (err:any):void =>
      {
          console.log(err);  //%//
          this.messages.push(err);
      }   // handleError

      this.messages = [];
      checkUser()
      .then(confirmAction)
      .then(getToken)
      .then(addUserAndSubscribe)
      .then(finish)
      .catch(handleError);
  } // establishSubscription

  terminateSubscription = ():void =>
  {
      let checkUser = (): Promise<any> =>
      {
          return new Promise((resolve,reject) =>
          {
              if (this.stripeCustomerID == '') reject('Current user ' + this.email + ' does not have a subscription');
              else resolve();
          });
      }   // checkUser

      let confirmAction = (): Promise<any> =>
      {
          return new Promise((resolve,reject) =>
          {
              let result = confirm(
`Do you wish to perform all of the following actions:\n
- Delete Stripe customer account\n
- Delete WizeFi user account\n
WARNING: these actions are irrevocable`
              );
              if (result) resolve();
              else reject('Terminate subscription action declined');
          });
      }   // confirmAction

      let deleteSubscription = (): Promise<any> =>
      {
        return new Promise((resolve,reject) =>
          {
            // set params to guide function invocation
            let payload_in =
            {
                email: this.email,
                stripeCustomerID: this.stripeCustomerID
            };
            let params =
            {
                FunctionName: 'terminateSubscription',
                Payload: JSON.stringify(payload_in)
            };

            // invoke Lambda function to process data
            this.dataModelService.dataModel.global.lambda.invoke(params, (err,data) =>
            {
                if (err)
                {
                    reject(JSON.stringify(err));
                }
                else
                {
                    if (!data.hasOwnProperty('Payload'))
                    {
                        console.log('Error in terminating subscription:');
                        console.log('Data does not contain Payload attribute');
                        reject('Error in terminating subscription')
                    }
                    else
                    {
                        let payload_out = JSON.parse(data.Payload);
                        if (payload_out.hasOwnProperty('errorMessage'))
                        {
                            console.log("errorMessage: " + payload_out.errorMessage);
                            reject('Error in terminating subscription')
                        }
                        else
                        {
                            resolve();
                        }
                    }
                }
            }); // lambda invoke
        });   // return new Promise
      }   // deleteSubscription

      let finish = (payload_out):void =>
      {
          console.log('Subscription has been terminated');  //%//
          this.messages.push('Subscription has been terminated');
      }   // finish

      let handleError = (err:any):void =>
      {
          console.log('Error in attempting to terminate subscription:');  //%//
          console.log(err);  //%//
          if (typeof err == 'string') this.messages.push(err);
          else this.messages.push('Error in attempting to terminate subscription');
      }   // handleError

      this.messages = [];
      checkUser()
      .then(confirmAction)
      .then(deleteSubscription)
      .then(finish)
      .catch(handleError);
  }   // terminateSubscription

} // class SubscriptionComponent
