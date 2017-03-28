import { CanDeactivate } from '@angular/router';
import { ProfileComponent } from './profile.component';

export class ProfileDeactivateGuard implements CanDeactivate<ProfileComponent> {

  canDeactivate(profileComponent: ProfileComponent) {
    console.log('canDeactivate called for ProfileComponent');
  	// console.log("isDirty: " + ProfileComponent.isPristine);

  	// update the application data model
  	profileComponent.update();
    console.log("memory resident data model has been updated");
    return true;
  }

}