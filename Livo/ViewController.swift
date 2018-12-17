//
//  ViewController.swift
//  Livo
//
//  Created by Skuerth on 2018/12/12.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YTLiveStreaming
import GoogleSignIn

class ViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {



    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        guard let token = user.authentication.accessToken else { return }
        GoogleOAuth2.sharedInstance.accessToken = token



    }


    @IBAction func signInButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube.force-ssl")

        GIDSignIn.sharedInstance()?.signIn()

    }
    @IBAction func signOutButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.signOut()

    }

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {


        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

        if let livePage = mainStoryBoard.instantiateViewController(withIdentifier: "LiveStreamingViewController") as? LiveStreamingViewController {

            present(livePage, animated: true, completion: nil)

        } else {

        }
    }
    

//    let input: YTLiveStreaming

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

