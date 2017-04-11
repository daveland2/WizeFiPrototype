import { Component, NgZone } from '@angular/core';

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

  constructor(private zone: NgZone) { }

  getToken() {
    this.messages = [];
    (<any>window).Stripe.card.createToken({
      number: this.cardNumber,
      exp_month: this.expiryMonth,
      exp_year: this.expiryYear,
      cvc: this.cvc
    },
    (status: number, response: any) => {
      // wrap inside Angular zone in order to catch updates
      this.zone.run(() => {
        if (status === 200) {
          this.messages.push('token: ' + response.card.id);
        }
        else {
          this.messages.push(response.error.message);
        }
      });
    });
  } // getToken

} // class SubscriptionComponent