import { Component, OnInit } from '@angular/core';

import { routes } from '../app.routes';

@Component({
  selector: 'app-site-map',
  templateUrl: './site-map.component.html',
  styleUrls: ['./site-map.component.css']
})
export class SiteMapComponent implements OnInit {

  linkInfo: {path: string, name: string}[];

  constructor() { }

  ngOnInit() {

  	// construct route information
  	this.linkInfo = [];
  	for (let i = 0; i < routes.length; i++) {
      let path = routes[i].path;
      if (path.length > 0) {
  	    this.linkInfo.push({path: '/' + path, name: path});
      }
    }
  }
}
