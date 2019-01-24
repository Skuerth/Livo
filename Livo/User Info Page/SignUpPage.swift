//
//  SignUpPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase
import Alertift

class SignUpPage: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var presentingView: UIView!

    var manager: RegisterManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.keyboardWillShowObserve()
        self.keyboardWillHideObserve()

        manager = RegisterManager()

        passwordTextField.isSecureTextEntry = true

        self.presentingView.backgroundColor = .white
        self.presentingView.layer.cornerRadius = 10

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
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

                let changeRequest = user.createProfileChangeRequest()

                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in

                    if let error = error {

                        UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
                    } else {

                        self.emailSignIn(email: email, password: password)
                    }
                })
            } else {

                UserInfoError.authorizationError.alert(message: "Fail to Sign up")
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

    func keyboardWillShowObserve() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    func keyboardWillHideObserve() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {

        presentingView.transform = CGAffineTransform(translationX: 0, y: -80)
    }

    @objc func keyboardWillHide(_ notification: Notification) {

        presentingView.transform = CGAffineTransform.identity
    }

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
