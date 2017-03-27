import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { routing } from './app.routes';

import { DataModelService } from './data-model.service';
import { AppComponent } from './app.component';
import { LoginComponent } from './login/login.component';
import { ProfileComponent } from './profile/profile.component';
import { BudgetComponent } from './budget/budget.component';
import { BudgetdetailsComponent } from './budget-details/budget-details.component';
import { IncomeComponent } from './income/income.component';
import { IncomedetailsComponent } from './income-details/income-details.component';

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
    FormsModule,
    routing
  ],
  providers: [DataModelService],
  bootstrap: [AppComponent]
})
export class AppModule { }
