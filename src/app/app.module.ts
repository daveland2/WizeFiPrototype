import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';  // delete this later?  //*//
import { HttpModule } from '@angular/http';    // delete this later?  //*//

import { routing } from './app.routes';

import { AppComponent } from './app.component';
import { LoginComponent } from './login/login.component';
import { ProfileComponent } from './profile/profile.component';
import { BudgetComponent } from './budget/budget.component';
import { BudgetdetailsComponent } from './budgetdetails/budgetdetails.component';
import { IncomeComponent } from './income/income.component';
import { IncomedetailsComponent } from './incomedetails/incomedetails.component';

@NgModule({
  declarations: [
    AppComponent,
    ProfileComponent,
    LoginComponent,
    BudgetComponent,
    BudgetdetailsComponent,
    IncomeComponent,
    IncomedetailsComponent
  ],
  imports: [
    BrowserModule,
    routing,
    FormsModule,  // delete this later?  //*//
    HttpModule    // delete this later?  //*//
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
