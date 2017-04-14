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

  constructor(private dataModelService: DataModelService) { }

  establishSubscription()
  {
      // initialize (code to simplify future references)
      let email = this.dataModelService.dataModel.global.email;
      let stripeUserID = this.dataModelService.dataModel.persistent.header.stripeUserID;

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
              if (result == true) resolve();
              else reject('Subscription action declined');
          });
      }   // confirmAction

      let checkUser = (): Promise<any> =>
      {
          return new Promise((resolve,reject) =>
          {
              if (stripeUserID != '') reject('Current user ' + email + ' is already registered for subscription');
              else resolve();
          });
      }   // checkUser

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
                email: this.dataModelService.dataModel.global.email,
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

      let finish = (payload_out): void =>
      {
          this.dataModelService.dataModel.persistent.header.stripeUserID = payload_out.stripeCustomerID;
          this.dataModelService.dataModel.persistent.header.stripeSubscriptionID = payload_out.stripeSubscriptionID;
          this.dataModelService.storedata();  // create WizeFi user account
          console.log('Subscription has been registered');  //%//
          this.messages.push('Subscription has been registered');
      }   // finish

      let handleError = (err:any): void =>
      {
          console.log(err);  //%//
          this.messages.push(err);
      }   // handleError

      this.messages = [];
      confirmAction()
      .then(checkUser)
      .then(getToken)
      .then(addUserAndSubscribe)
      .then(finish)
      .catch(handleError);
  } // establishSubscription

} // class SubscriptionComponent
