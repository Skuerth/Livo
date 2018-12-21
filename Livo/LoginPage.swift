//
//  LoginPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/12.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YTLiveStreaming
import GoogleSignIn

class LoginPage: UIViewController, GIDSignInUIDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()

    }

//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//
//        guard let token = user.authentication.accessToken else { return }
//        GoogleOAuth2.sharedInstance.accessToken = token
//    }

    @IBAction func signInButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
//        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
//        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")

        GIDSignIn.sharedInstance()?.scopes = ["https://www.googleapis.com/auth/youtube","https://www.googleapis.com/auth/youtube.force-ssl"]

        guard let scopes = GIDSignIn.sharedInstance()?.scopes as? [String] else { return }

        if scopes.count > 0 {

            for scope in scopes {

                print("scope", scope)
            }
        }

        GIDSignIn.sharedInstance()?.signIn()

    }
    @IBAction func signOutButton(_ sender: UIButton) {

//        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signOut()

    }

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {

        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

        if let addingPage = mainStoryBoard.instantiateViewController(withIdentifier: "AddLiveBraodcastStreamPage") as? AddLiveBraodcastStreamPage {

            present(addingPage, animated: true, completion: nil)

        } else {

        }
    }
}
