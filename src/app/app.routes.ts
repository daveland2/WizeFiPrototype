import { Routes, RouterModule } from '@angular/router';

import { LoginComponent } from './login/login.component';
import { SiteMapComponent } from './site-map/site-map.component';
import { ProfileComponent } from './profile/profile.component';
import { ProfileDeactivateGuard } from './profile/profile-deactivate.guard';
import { BudgetSummaryComponent } from './budget-summary/budget-summary.component';
import { BudgetDetailsComponent } from './budget-details/budget-details.component';
import { BudgetDetailsDeactivateGuard } from './budget-details/budget-details-deactivate.guard';
import { IncomeComponent } from './income/income.component';
import { IncomeDetailsComponent } from './income-details/income-details.component';
import { IncomeDetailsDeactivateGuard } from './income-details/income-details-deactivate.guard';
import { ExpensesComponent } from './expenses/expenses.component';
import { ExpensesDeactivateGuard } from './expenses/expenses-deactivate.guard';
import { AssetsComponent } from './assets/assets.component';
import { AssetsDeactivateGuard } from './assets/assets-deactivate.guard';
import { Assets2Component } from './assets2/assets2.component';
import { Assets2DeactivateGuard } from './assets2/assets2-deactivate.guard';
import { LogoutComponent } from './logout/logout.component';
import { SettingsComponent } from './settings/settings.component';
import { SettingsDeactivateGuard } from './settings/settings-deactivate.guard';
import { SubscriptionComponent } from './subscription/subscription.component';
import { ManagePlansComponent } from './manage-plans/manage-plans.component';
import { ManagePlansDeactivateGuard } from './manage-plans/manage-plans-deactivate.guard';
import { ScreenLoginGuard } from './utilities/screen-login.guard';

export const routes: Routes = [
  {
    path: 'login',
    component: LoginComponent,
  },
  {
    path: 'profile',
    component: ProfileComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [ProfileDeactivateGuard]
  },
  {
    path: 'budget-summary',
    component: BudgetSummaryComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'budget-details',
    component: BudgetDetailsComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [BudgetDetailsDeactivateGuard]
  },
  {
    path: 'income',
    component: IncomeComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'income-details',
    component: IncomeDetailsComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [IncomeDetailsDeactivateGuard]
  },
  {
    path: 'expenses',
    component: ExpensesComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [ExpensesDeactivateGuard]
  },
  {
    path: 'assets',
    component: AssetsComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [AssetsDeactivateGuard]
  },
  {
    path: 'assets2',
    component: Assets2Component,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [Assets2DeactivateGuard]
  },
  {
    path: 'subscription',
    component: SubscriptionComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'manage-plans',
    component: ManagePlansComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [ManagePlansDeactivateGuard],
  },
  {
    path: 'settings',
    component: SettingsComponent,
    canActivate: [ScreenLoginGuard],
    canDeactivate: [SettingsDeactivateGuard]
  },
  {
    path: 'logout',
    component: LogoutComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'site-map',
    component: SiteMapComponent,
  },
  {
    path: '',
    redirectTo: '/login',
    pathMatch: 'full'
  }
];

export const routing = RouterModule.forRoot(routes);