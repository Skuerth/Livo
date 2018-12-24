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
import Firebase

class LoginPage: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var manager: RegisterManager?
    var userProfile: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager = RegisterManager()

        Auth.auth().addStateDidChangeListener { (auth, user) in

            guard
                let uid = user?.uid,
                let email = user?.email
            else {
                return
            }

            let name = user?.displayName

            let userProfile = UserProfile(name: name, email: email, password: nil, emailLogInUID: uid)

            let main = UIStoryboard(name: "Main", bundle: nil)

            if let mainTabbarPage = main.instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

                mainTabbarPage.emailUserProfile = userProfile
                self.present(mainTabbarPage, animated: true, completion: nil)

            } else {

                print("can't present mainTabbarPage")
            }
        }
    }

    @IBAction func emailSignInButton(_ sender: UIButton) {

        guard
            let email = emailTextField.text,
            let password = passwordTextField.text
        else {
            return
        }

        self.manager?.emailSignIn(email: email, password: password)
        self.manager?.delegate = self
    }

    @IBAction func emailSignUpButton(_ sender: UIButton) {


        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpPage = mainStoryBoard.instantiateViewController(withIdentifier: "SignUpPage") as? SignUpPage {

            addChild(signUpPage)
            self.view.addSubview(signUpPage.view)
            signUpPage.didMove(toParent: self)
        }
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

extension LoginPage: RegisterManagerDelegate {

    func didEmailSignIn(manager: RegisterManager, userProfile: UserProfile) {

        let main = UIStoryboard(name: "Main", bundle: nil)

        if let mainTabbarPage = main.instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

            mainTabbarPage.emailUserProfile = userProfile
            self.present(mainTabbarPage, animated: true, completion: nil)
        }
    }
}
