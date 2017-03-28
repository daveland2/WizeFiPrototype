import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model.service';
import { CProfile } from './profile.class';
import { ProfileDeactivateGuard } from './profile-deactivate.guard';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css']
})
export class ProfileComponent implements OnInit {
  // persistent data
  cProfile: CProfile;

  constructor(private datamodelService: DataModelService) { }

  ngOnInit() {
    this.cProfile = new CProfile(this.datamodelService.getdata('profile'));
  }

  // update data model
  update() {
    this.datamodelService.putdata('profile', this.cProfile.profile);
  }

}
