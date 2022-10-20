####################
# create workspace #
####################

ng new --create-application=false WORKSPACE_NAME
cd WORKSPACE_NAME


###################################################
# add an Angular application to Angular workspace #
###################################################
ng g application --inline-style --inline-template --routing --style=scss "APP_NAME"


###########################################
# Add an Angular lib to Angular workspace #
###########################################
# This lib is generated by `openapitools` from the OpenAPI spec file produced by APP_NAME REST API (with `mvn clean verify -Popenapi`)
ng g library @c4-soft/API_LIB_NAME
npm i -D @openapitools/openapi-generator-cli
npx openapi-generator-cli version-manager set 6.0.0-beta
sed -i 's/"ng": "ng",/"ng": "ng",\
    "postinstall": "npm run API_LIB_NAME:install",\
    "API_LIB_NAME:generate": "npx openapi-generator-cli generate -i ..\/API_SPEC_FILE -g typescript-angular --type-mappings AnyType=any --additional-properties=serviceSuffix=Api,npmName=@c4-soft\/API_LIB_NAME,npmVersion=0.0.1,enumPropertyNaming=camelCase,supportsES6=true,withInterfaces=true --remove-operation-id-prefix -o projects\/c4-soft\/API_LIB_NAME",\
    "API_LIB_NAME:build": "npm run API_LIB_NAME:generate \&\& npm run ng -- build @c4-soft\/API_LIB_NAME --configuration production",\
    "API_LIB_NAME:install": "cd projects\/c4-soft\/API_LIB_NAME \&\& npm i \&\& cd ..\/..\/.. \&\& npm run API_LIB_NAME:build",/' ./package.json
cp ../angular-ionic-workspace-template/openapitools.json ./
sed -i 's/"entryFile": "src\/public-api.ts"/"entryFile": "index.ts"/' ./projects/c4-soft/API_LIB_NAME/ng-package.json
cp ../angular-ionic-workspace-template/.openapi-generator-ignore ./projects/c4-soft/API_LIB_NAME/.openapi-generator-ignore
cp ../angular-ionic-workspace-template/.gitignore ./projects/c4-soft/API_LIB_NAME/.gitignore
cp ../angular-ionic-workspace-template/package.json ./projects/c4-soft/API_LIB_NAME/package.json
sed -i 's/"$schema": ".\/node_modules\/ng-packagr\/ng-package.schema.json"/"$schema": ".\/node_modules\/ng-packagr\/ng-package.schema.json",\
  "dest": "..\/..\/..\/dist\/c4-soft\/API_LIB_NAME"/' ./projects/c4-soft/API_LIB_NAME/ng-package.json
cp ../angular-ionic-workspace-template/tsconfig.lib.json ./projects/c4-soft/API_LIB_NAME/tsconfig.lib.json
cp ../angular-ionic-workspace-template/tsconfig.lib.prod.json ./projects/c4-soft/API_LIB_NAME/tsconfig.lib.prod.json
npm i


#################################################
# Make Angular application an Ionic-Angular app #
#################################################

# dependencies
npm i -D @ionic/angular-toolkit
cd "./projects/APP_NAME/"
npm init --yes
npm i @capacitor/core @capacitor/app @capacitor/haptics @capacitor/keyboard @capacitor/status-bar @ionic/angular ionicons @awesome-cordova-plugins/core @ionic/storage-angular ionic-plugin-deeplinks @awesome-cordova-plugins/deeplinks
npm i -D @capacitor/cli
cd ../..

# add ionicons to app assets
sed -i 's/"projects\/APP_NAME\/src\/assets"/"projects\/APP_NAME\/src\/assets",\
              { "glob": "**\/*.svg", "input": "projects\/APP_NAME\/node_modules\/ionicons\/dist\/ionicons\/svg", "output": ".\/svg" }/' ./angular.json

# add Ionic theme style sheet
cp ../angular-ionic-workspace-template/styles.scss "./projects/APP_NAME/src/styles.scss"

# replace index.html
cp ../angular-ionic-workspace-template/index.html ./projects/APP_NAME/src/index.html

# add Ionic imports & providers in app module
echo -e "import { IonicModule, IonicRouteStrategy } from '@ionic/angular';\n\
import { IonicStorageModule } from '@ionic/storage-angular';\n\
import { Deeplinks } from '@awesome-cordova-plugins/deeplinks/ngx';\n\
import { RouteReuseStrategy } from '@angular/router';\n\
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';\n\
$(cat ./projects/APP_NAME/src/app/app.module.ts)" > ./projects/APP_NAME/src/app/app.module.ts
sed -i 's/BrowserModule,/BrowserModule,\
    HttpClientModule,\
    IonicModule.forRoot(),\
    IonicStorageModule.forRoot(),/' "./projects/APP_NAME/src/app/app.module.ts"
sed -i 's/providers: \[\]/providers: \[\
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy },\
    Deeplinks,\
  ]/' "./projects/APP_NAME/src/app/app.module.ts"
ng build APP_NAME

# init Ionic and Capacitor tooling
ionic init --multi-app
cd "./projects/APP_NAME/"
winpty npx.cmd cap init "APP_NAME" CAPACITOR_ID --web-dir "../../dist/APP_NAME"
ionic init --type=angular "APP_NAME" --default
ionic capacitor add android
cd ../..
rm ./capacitor.config.ts

# add useful npm targets
sed -i 's/"test": "echo \\"Error: no test specified\\" \&\& exit 1"/"test": "ionic test",\
    "build": "ionic build",\
    "serve": "ionic serve",\
    "android": "ionic capacitor run android -l"/' ./projects/APP_NAME/package.json

sed -i 's/"start": "ng serve"/"APP_NAME:serve": "cd projects\/APP_NAME \&\& npm run serve",\
    "APP_NAME:android": "cd projects\/APP_NAME \&\& npm run android"/' ./package.json
sed -i 's/"build": "ng build"/"APP_NAME:build": "cd projects\/APP_NAME \&\& npm run build"/' ./package.json
sed -i 's/"test": "ng test"/"APP_NAME:test": "cd projects\/APP_NAME \&\& npm run test"/' ./package.json
sed -i '/"watch":/d' ./package.json

#####################################
# Add Material for Angular and OIDC #
#####################################

winpty ng.cmd add @angular/material

npm i angular-auth-oidc-client @angular/flex-layout @angular/cdk

# add OIDC conf to environment files
echo -e "import { LogLevel, PassedInitialConfig } from 'angular-auth-oidc-client';\n\
\n\
export const authConfig: PassedInitialConfig = {\n\
  config: {\n\
    authority: 'https://dev-ch4mpy.eu.auth0.com',\n\
    redirectUrl: window.location.origin,\n\
    postLogoutRedirectUri: window.location.origin,\n\
    clientId: 'lRHwmwQr3bhkKZeezYD8UAaGna3KSnBB',\n\
    scope: 'openid profile email offline_access solutions:manage',\n\
    responseType: 'code',\n\
    silentRenew: true,\n\
    useRefreshToken: true,\n\
    logLevel: LogLevel.Debug,\n\
  }\n\
};\n\
\n\
export const environment = {\n\
  production: true,\n\
  authConfig,\n\
};" > ./projects/APP_NAME/src/environments/environment.ts
echo -e "import { LogLevel, PassedInitialConfig } from 'angular-auth-oidc-client';\n\
\n\
export const authConfig: PassedInitialConfig = {\n\
  config: {\n\
    authority: 'https://dev-ch4mpy.eu.auth0.com',\n\
    redirectUrl: window.location.origin,\n\
    postLogoutRedirectUri: window.location.origin,\n\
    clientId: 'lRHwmwQr3bhkKZeezYD8UAaGna3KSnBB',\n\
    scope: 'openid profile email offline_access solutions:manage',\n\
    responseType: 'code',\n\
    silentRenew: true,\n\
    useRefreshToken: true,\n\
    logLevel: LogLevel.Debug,\n\
  }\n\
};\n\
\n\
export const environment = {\n\
  production: true,\n\
  authConfig,\n\
};" > "./projects/APP_NAME/src/environments/environment.prod.ts"

# import OAuthModule in app module
echo -e "import { AuthModule } from 'angular-auth-oidc-client';\n\
import { MatDialogModule } from '@angular/material/dialog';\n\
import { environment } from '../environments/environment';\n\
$(cat ./projects/APP_NAME/src/app/app.module.ts)" > "./projects/APP_NAME/src/app/app.module.ts"
sed -i 's/imports: \[/imports: \[\
    AuthModule.forRoot(environment.authConfig),\
    MatDialogModule,/' "./projects/APP_NAME/src/app/app.module.ts"


##################################################################################################
# Replace Angular minimal app with an Ionic app composed of a menu in a split-pane and two pages #
##################################################################################################

cd projects/APP_NAME/src/app/

# handle http errors
ng g c --type=dialog --flat -s -t NetworkError

cp ../../../../../angular-ionic-workspace-template/network-error.dialog.ts "./network-error.dialog.ts"
cp ../../../../../angular-ionic-workspace-template/error-http-interceptor.ts "./error-http-interceptor.ts"
cp ../../../../../angular-ionic-workspace-template/user.service.ts "./user.service.ts"

echo -e "import { ErrorHttpInterceptor } from './error-http-interceptor';\n\
$(cat ./app.module.ts)" > "./app.module.ts"
sed -i 's/providers: \[/providers: \[\
    {\
      provide: HTTP_INTERCEPTORS,\
      useClass: ErrorHttpInterceptor,\
      multi: true,\
    },\' "./app.module.ts"

# copy default content
cp ../../../../../angular-ionic-workspace-template/loading.service.ts "./loading.service.ts"
cp ../../../../../angular-ionic-workspace-template/has-role.guard.ts "./has-role.guard.ts"

ng g c --type=screen --flat -s -t home
cp ../../../../../angular-ionic-workspace-template/home.screen.ts "./home.screen.ts"

ng g module --routing user-account
echo -e "import { FormsModule, ReactiveFormsModule } from '@angular/forms';\n\
import { IonicModule } from '@ionic/angular';\n\
$(cat ./user-account/user-account.module.ts)" > "./user-account/user-account.module.ts"
sed -i 's/CommonModule,/CommonModule,\
    FormsModule,\
    ReactiveFormsModule,\
    IonicModule,/' "./user-account/user-account.module.ts"
ng g c --type=screen --flat -s -t -m=user-account user-account/UserAccount
cp ../../../../../angular-ionic-workspace-template/user-account.screen.ts "./user-account/user-account.screen.ts"
cp ../../../../../angular-ionic-workspace-template/user-account-routing.module.ts "./user-account/user-account-routing.module.ts"

cp ../../../../../angular-ionic-workspace-template/app-routing.module.ts "./app-routing.module.ts"
cp ../../../../../angular-ionic-workspace-template/app.component.ts "./app.component.ts"

cd ../../../../
sed -i 's/\/node_modules/**\/node_modules/' ./.gitignore
git add ionic.config.json openapitools.json projects/ .gitignore angular.json package-lock.json package.json tsconfig.json
