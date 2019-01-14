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
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        GIDSignIn.sharedInstance()?.clientID = LivoCredentials.oAuthClientID

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        guard let gai = GAI.sharedInstance() else {

            assert(false, "Google Analytics not configured correctly")
            return true
        }

        gai.tracker(withTrackingId: "UA-131669168-1")
        gai.trackUncaughtExceptions = true

        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        GIDSignIn.sharedInstance()?.scopes = ["https://www.googleapis.com/auth/youtube","https://www.googleapis.com/auth/youtube.force-ssl"]
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }
}
