import { CanDeactivate } from '@angular/router';
import { ProfileComponent } from './profile.component';

export class ProfileDeactivateGuard implements CanDeactivate<ProfileComponent> {

  canDeactivate(profileComponent: ProfileComponent) {
  	profileComponent.update();
    return true;
  }

}