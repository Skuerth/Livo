//
//  MainTabbarPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/23.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import YTLiveStreaming

class MainTabbarPage: UITabBarController {

    var userProfile: [String: String]?
    var liveStreamManager: LiveStreamManager?
    var emailUserProfile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.liveStreamManager = LiveStreamManager()

        GIDSignIn.sharedInstance()?.delegate = self
    }
}

// MARK: - GIDSignInDelegate Method
extension MainTabbarPage: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        guard let token = user.authentication.accessToken else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: token)
        Auth.auth().signInAndRetrieveData(with: credential) { authDataResult, error in

            if let error = error {
                print("error", error)
                return
            }

            guard
                let userName = user.profile.name,
                let userUID = user.userID,
                let imageURL = user.profile.imageURL(withDimension: 150),
                var userProfile = self.userProfile
            else { return }

            let imageURLString = imageURL.absoluteString

            userProfile["userName"] = userName
            userProfile["userUID"] = userUID
            userProfile["imageURL"] = imageURLString
            self.liveStreamManager?.userProfile = userProfile

            GoogleOAuth2.sharedInstance.accessToken = token
        }
    }
}
