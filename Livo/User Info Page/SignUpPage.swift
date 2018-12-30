//
//  SignUpPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase

enum SignUpError: Error {

    case noInput
}

class SignUpPage: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var presentingView: UIView!

    @IBOutlet weak var blueEffectView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presentingView.backgroundColor = .white
        self.presentingView.layer.cornerRadius = 10

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

//        let blueEffect = UIBlurEffect(style: .dark)
//        let blueView = UIVisualEffectView(effect: blueEffect)
//        blueView.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
//        self.blueEffectView.addSubview(blueView)
    }

    @IBAction func signUpButton(_ sender: UIButton) {

        guard
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            let name = self.nameTextField.text
        else {

            print("Plese fill up necessary information")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in

            if let error = error {

                print(error.localizedDescription)
                return
            }

            if let user = Auth.auth().currentUser {

                let changeRequest = user.createProfileChangeRequest()


                changeRequest.displayName = name

                changeRequest.commitChanges(completion: { (error) in

                    if let error = error {

                        print("fail to requesting chane displayNme with error(\(error.localizedDescription))")

                    } else {

                        self.emailSignIn(email: email, password: password)
                    }
                })
            }

        }
    }

    @IBAction func exitButton(_ sender: UIButton) {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    func emailSignIn(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in

//            guard
//                let uid = result?.user.uid,
//                let displayName = result?.user.displayName
//                else {
//                    return
//            }

//            let userProfile = UserProfile(name: displayName, email: email, password: password, emailLogInUID: uid, photo: nil)

            if let mainTabbarPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

//                mainTabbarPage.emailUserProfile = userProfile

                self.present(mainTabbarPage, animated: true, completion: nil)
            }
        })

    }
}
