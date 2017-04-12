import { Component } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { ManageMessages } from '../utilities/manage-messages.class';

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
      // kludge to get information into scope of nested function
      let dataModelService = this.dataModelService;
      let cardNumber = this.cardNumber;
      let expiryMonth = this.expiryMonth;
      let expiryYear = this.expiryYear;
      let cvc = this.cvc;
      let messages = this.messages;

      function getToken()
      {
        (<any>window).Stripe.card.createToken(
        {
            number: cardNumber,
            exp_month: expiryMonth,
            exp_year: expiryYear,
            cvc: cvc
        },
        (status: number, response: any) =>
        {
            if (status === 200)
            {
                console.log('sourceToken:  ' + response.id);
                // this.messages.push('token: ' + response.id);
                //this.manageMessages.update(messages,'');
            }
            else
            {
                this.manageMessages.update(response.error.message);
            }
        });
      }

      messages = [];
      getToken();
  } // establishSubscription

} // class SubscriptionComponent
