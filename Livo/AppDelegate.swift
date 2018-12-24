//
//  AppDelegate.swift
//  Livo
//
//  Created by Skuerth on 2018/12/12.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import GoogleSignIn
import YTLiveStreaming
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        print("xxx")
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        GIDSignIn.sharedInstance()?.clientID = LivoCredentials.oAuthClientID
        GIDSignIn.sharedInstance()?.delegate = self

        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

        if GIDSignIn.sharedInstance()?.hasAuthInKeychain() != nil {

            if let mainTabbarPage = mainStoryBoard.instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

                self.window?.rootViewController = mainTabbarPage
            }

        } else {

            if let loginPage = mainStoryBoard.instantiateViewController(withIdentifier: "LoginPage") as? LoginPage {

                self.window?.rootViewController = loginPage
            }
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        GIDSignIn.sharedInstance()?.scopes = ["https://www.googleapis.com/auth/youtube","https://www.googleapis.com/auth/youtube.force-ssl"]
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
}
