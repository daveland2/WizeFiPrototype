import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot} from '@angular/router';

import { DataModelService } from '../data-model.service';

@Injectable()
export class ScreenLoginGuard implements CanActivate {

    constructor(private router: Router, private dataModelService: DataModelService) { }

    canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
        if (state.url !== '/login' && !this.dataModelService.dataModel.global.isLoggedIn) {
            this.router.navigateByUrl('/login');
            return false;
        }
        return true;
    }   // canActivate
}