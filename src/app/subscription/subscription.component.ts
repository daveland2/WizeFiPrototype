import { Component, OnInit, NgZone } from '@angular/core';

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

  constructor(private zone: NgZone) { }

  message: string;

  getToken() {
    this.message = 'Loading...';

    (<any>window).Stripe.card.createToken({
      number: this.cardNumber,
      exp_month: this.expiryMonth,
      exp_year: this.expiryYear,
      cvc: this.cvc
    }, (status: number, response: any) => {

      // Wrapping inside the Angular zone
      this.zone.run(() => {
        if (status === 200) {
          this.message = 'token: ' + response.card.id;
        } else {
          this.message = response.error.message;
        }
      });
    });
  }

}
