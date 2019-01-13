//
//  SignUpPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase

class SignUpPage: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var presentingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.isSecureTextEntry = true

        self.presentingView.backgroundColor = .white
        self.presentingView.layer.cornerRadius = 10

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    @IBAction func signUpButton(_ sender: UIButton) {

        guard
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            let name = self.nameTextField.text
        else {

            UserInfoError.infoError.alert(message: "Plese fill up required information")

            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in

            if let error = error {

                UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
                return
            }

            if let user = Auth.auth().currentUser {

                guard
                    let email = user.email,
                    let name = user.displayName
                    else {
                        return
                }
                let uid = user.uid

                UserShareInstance.sharedInstance().createUser(name: name, email: email, emailLogInUID: uid, photo: nil)

                let changeRequest = user.createProfileChangeRequest()

                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in

                    if let error = error {

                        UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
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

            guard
                let uid = result?.user.uid,
                let displayName = result?.user.displayName
                else {

                    UserInfoError.authorizationError.alert(message: "fail to get user infomation ")
                    return
            }

            if let mainTabbarPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

                self.present(mainTabbarPage, animated: true, completion: nil)
            }
        })
    }
}

extension SignUpPage: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()

        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.view.endEditing(true)
    }
}
