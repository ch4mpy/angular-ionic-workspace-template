import { Injectable } from '@angular/core';
import { LoadingController } from '@ionic/angular';
import { OidcSecurityService } from 'angular-auth-oidc-client';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  name!: string;
  picture!: string;
  sub!: string;
  _idClaims: any;

  private loading: Promise<HTMLIonLoadingElement>;

  constructor(
    private authService: OidcSecurityService,
    loadingCtrl: LoadingController
  ) {
    this.loading = loadingCtrl.create({ duration: 10000 });
    this.refreshUserData(undefined);
    this.authService
      .checkAuth()
      .subscribe(({ isAuthenticated, userData, accessToken, idToken }) => {
        console.log(isAuthenticated, userData, accessToken, idToken);
        this.refreshUserData(userData);
      });
  }

  get isAuthenticated(): boolean {
    return !!this.sub;
  }

  login() {
    this.loading.then((l) => l.present());
    this.authService.authorize();
  }

  logout() {
    this.authService.logoff();
    this.refreshUserData(undefined);
  }

  private refreshUserData(idClaims: any) {
    console.log('refreshUserData: ', idClaims);
    this._idClaims = idClaims || {};
    this.name = idClaims?.name || '';
    this.sub = idClaims?.sub || '';
    this.picture = idClaims?.picture || '';
  }

  get idClaims() {
    return this._idClaims;
  }
}
