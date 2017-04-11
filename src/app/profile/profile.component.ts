import { Component, OnInit } from '@angular/core';

import { DataModelService } from '../data-model/data-model.service';
import { CProfile } from './profile.class';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css']
})
export class ProfileComponent implements OnInit {
  // persistent data
  cProfile: CProfile;

  constructor(private dataModelService: DataModelService) { }

  ngOnInit() {
    this.cProfile = new CProfile(this.dataModelService.getdata('profile'));
  }

  // update data model
  update() {
    this.dataModelService.putdata('profile', this.cProfile.profile);
  }

}
