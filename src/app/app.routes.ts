import { Routes, RouterModule } from '@angular/router';

import { LoginComponent } from './login/login.component';
import { ProfileComponent } from './profile/profile.component';
import { BudgetComponent } from './budget/budget.component';
import { BudgetdetailsComponent } from './budget-details/budget-details.component';
import { IncomeComponent } from './income/income.component';
import { IncomedetailsComponent } from './income-details/income-details.component';

const routes: Routes = [
  {
    path: 'login',
    component: LoginComponent,
  },
  {
    path: 'profile',
    component: ProfileComponent,
  },
  {
    path: 'budget',
    component: BudgetComponent,
  },
  {
    path: 'budget-details',
    component: BudgetdetailsComponent,
  },
  {
    path: 'income',
    component: IncomeComponent,
  },
  {
    path: 'income-details',
    component: IncomedetailsComponent,
  },
  {
    path: '',
    redirectTo: '/login',
    pathMatch: 'full'
  }
];

export const routing = RouterModule.forRoot(routes);