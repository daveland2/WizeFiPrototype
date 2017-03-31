import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

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
    BudgetDetailsDeactivateGuard
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
