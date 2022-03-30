import { ChangeDetectorRef, Injectable } from '@angular/core';
import { LoadingController } from '@ionic/angular';
import { OAuthService } from 'angular-oauth2-oidc';
import { environment } from '../environments/environment';

@Injectable({
  providedIn: 'root',
})
export class UserService {
  name!: string;
  picture!: string;
  sub!: string;

  private loading: Promise<HTMLIonLoadingElement>;

  constructor(
    private oauthService: OAuthService,
    loadingCtrl: LoadingController
  ) {
    this.loading = loadingCtrl.create({ duration: 10000 });
    this.refreshUserData(undefined);
    this.oauthService.configure(environment.authConfig);
    this.refresh();
  }

  get isAuthenticated(): boolean {
    return !!this.sub;
  }

  async refresh() {
    if (!this.oauthService.discoveryDocumentLoaded) {
      this.loading.then((l) => l.present());
      await this.oauthService.loadDiscoveryDocument();
      this.loading.then((l) => l.dismiss());
    }
    if (
      !!this.oauthService.getIdentityClaims() &&
      this.oauthService.hasValidAccessToken()
    ) {
      this.refreshUserData(this.oauthService.getIdentityClaims());
    } else {
      this.loading.then((l) => l.present());
      await this.oauthService
        .tryLogin()
        .then(async (loginResp) => {
          console.log('loginResp: ', loginResp);
          if (!this.oauthService.hasValidAccessToken()) {
            await this.oauthService.silentRefresh();
          }
        })
        .then(() => {
          this.refreshUserData(this.oauthService.getIdentityClaims());
        })
        .finally(() => this.loading.then((l) => l.dismiss()));
    }
  }

  login() {
    this.loading.then((l) => l.present());
    this.oauthService.initLoginFlow();
    this.oauthService
      .tryLogin()
      .then(
        (isSuccess) => {
          console.log('Login isSuccess: ', isSuccess);
          if (isSuccess) {
            this.refreshUserData(this.oauthService.getIdentityClaims());
          } else {
            this.refreshUserData(undefined);
          }
        },
        (error) => console.log('Login error: ', error)
      )
      .finally(() => this.loading.then((l) => l.dismiss()));
  }

  logout() {
    this.oauthService.revokeTokenAndLogout();
    this.refreshUserData(undefined);
  }

  private refreshUserData(idClaims: any) {
    console.log('refreshUserData: ', idClaims);
    this.name = idClaims?.name || '';
    this.sub = idClaims?.sub || '';
    this.picture = idClaims?.picture || '';
  }

  get idClaims() {
    return this.oauthService.getIdentityClaims();
  }
}
