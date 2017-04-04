import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LOCALE_ID } from '@angular/core';

import { routing } from './app.routes';

import { DataModelService } from './data-model.service';
import { AppComponent } from './app.component';
import { LoginComponent } from './login/login.component';
import { ProfileComponent } from './profile/profile.component';
import { ProfileDeactivateGuard } from './profile/profile-deactivate.guard';
import { BudgetComponent } from './budget/budget.component';
import { BudgetDetailsComponent } from './budget-details/budget-details.component';
import { BudgetDetailsDeactivateGuard } from './budget-details/budget-details-deactivate.guard';
import { IncomeComponent } from './income/income.component';
import { IncomeDetailsComponent } from './income-details/income-details.component';
import { IncomeDetailsDeactivateGuard } from './income-details/income-details-deactivate.guard';
import { SiteMapComponent } from './site-map/site-map.component';
import { LogoutComponent } from './logout/logout.component';

@NgModule({
  declarations: [
    AppComponent,
    ProfileComponent,
    LoginComponent,
    BudgetComponent,
    BudgetDetailsComponent,
    IncomeComponent,
    IncomeDetailsComponent,
    SiteMapComponent,
    LogoutComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    routing
  ],
  providers: [
    DataModelService,
    ProfileDeactivateGuard,
    BudgetDetailsDeactivateGuard,
    IncomeDetailsDeactivateGuard,
//  {provide: LOCALE_ID, useValue: "en-US" }  // 4,294,967,295.00  (get expected result)  <=== default value in local tests
//  {provide: LOCALE_ID, useValue: "de-DE" }  // 4.294.967.295,00  (get expected result)
//  {provide: LOCALE_ID, useValue: "fr-FR" }  // 4 294 967 295,00  (get expected result)
//  {provide: LOCALE_ID, useValue: "nb-NO" }  // 4.294.967.295,00  (get space, not .)
//  {provide: LOCALE_ID, useValue: "it-IT" }  // 4'294'967'295,00  (get . not ')
//  {provide: LOCALE_ID, useValue: "ja-JP" }  // 4'294'967'295,00  (get . not ')
    // note: for currency pipe, default is USD and locale has no effect on which currency is in effect
    //       currency symbol for locale is NOT used
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
