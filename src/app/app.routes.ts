import { Routes, RouterModule } from '@angular/router';

import { LoginComponent } from './login/login.component';
import { SiteMapComponent } from './site-map/site-map.component';
import { ProfileComponent } from './profile/profile.component';
import { ProfileDeactivateGuard } from './profile/profile-deactivate.guard';
import { BudgetComponent } from './budget/budget.component';
import { BudgetDetailsComponent } from './budget-details/budget-details.component';
import { BudgetDetailsDeactivateGuard } from './budget-details/budget-details-deactivate.guard';
import { IncomeComponent } from './income/income.component';
import { IncomeDetailsComponent } from './income-details/income-details.component';
import { IncomeDetailsDeactivateGuard } from './income-details/income-details-deactivate.guard';
import { LogoutComponent } from './logout/logout.component';
import { SettingsComponent } from './settings/settings.component';
import { SettingsDeactivateGuard } from './settings/settings-deactivate.guard';
import { SubscriptionComponent } from './subscription/subscription.component';
import { ScreenLoginGuard } from './utilities/screen-login.guard';

export const routes: Routes = [
  {
    path: 'login',
    component: LoginComponent,
  },
  {
    path: 'profile',
    component: ProfileComponent,
    canDeactivate: [ProfileDeactivateGuard],
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'budget',
    component: BudgetComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'budget-details',
    component: BudgetDetailsComponent,
    canDeactivate: [BudgetDetailsDeactivateGuard],
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'income',
    component: IncomeComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'income-details',
    component: IncomeDetailsComponent,
    canDeactivate: [IncomeDetailsDeactivateGuard],
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'subscription',
    component: SubscriptionComponent,
    canActivate: [ScreenLoginGuard]
  },
  {
    path: 'settings',
    component: SettingsComponent,
    canDeactivate: [SettingsDeactivateGuard],
    canActivate: [ScreenLoginGuard]
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