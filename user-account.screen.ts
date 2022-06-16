import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UserService } from '../user.service';

@Component({
  selector: 'app-user-account',
  template: `<ion-header>
      <ion-toolbar translucent color="primary">
        <ion-buttons slot="start">
          <ion-menu-button></ion-menu-button>
        </ion-buttons>
        <ion-title>{{ user.current.displayName || 'Compte' }}</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content>
        <button mat-raised-button (click)="logout()">Logout</button>
    </ion-content>`,
  styles: [],
})
export class UserAccountScreen implements OnInit {
  constructor(readonly user: UserService, private router: Router) {}

  ngOnInit() {}

  logout() {
    this.user.logout();
    this.router.navigate(['/'])
  }
}
