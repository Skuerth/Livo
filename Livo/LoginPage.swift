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

    @IBAction func signInButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = [
            "https://www.googleapis.com/auth/youtube",
            "https://www.googleapis.com/auth/youtube.force-ssl"]
        GIDSignIn.sharedInstance()?.signIn()
    }

    @IBAction func signOutButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signOut()
    }

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {

        if error != nil {

            print("signing in someting wrong")
            return

        } else {

            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

            if let mainTabbarPage = mainStoryBoard.instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

                present(mainTabbarPage, animated: true, completion: nil)
            } else {

            }
        }

    }
}
