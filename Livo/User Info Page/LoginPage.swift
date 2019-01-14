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
import Alertift

class LoginPage: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelTextFieldContainer: UIView!

    var manager: RegisterManager?
    var userProfile: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.keyboardWillShowObserve()
        self.keyboardWillHideObserve()

        setupButtonStyle(button: signInButton)
        setupButtonStyle(button: signUpButton)
        titleLabel.addCharacterSpacing(kernValue: 5)

        passwordTextField.isSecureTextEntry = true

        self.manager = RegisterManager()

    }

    override func viewDidAppear(_ animated: Bool) {

        if let currentUser = Auth.auth().currentUser {

            guard
                let email = currentUser.email,
                let name = currentUser.displayName
                else {
                    return
            }

            let uid = currentUser.uid

            UserShareInstance.sharedInstance().createUser(name: name, email: email, emailLogInUID: uid, photo: nil)

            if let mainTabbarPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

                self.present(mainTabbarPage, animated: true, completion: nil)
            }

        } else {

        }
    }

    @IBAction func emailSignInButton(_ sender: UIButton) {

        guard
            emailTextField.text != "",
            let email = emailTextField.text
        else {
            UserInfoError.infoError.alert(message: "required email")
            return
        }
        guard
            passwordTextField.text != "",
            let password = passwordTextField.text
        else {
            UserInfoError.infoError.alert(message: "required password")
            return
        }

        self.manager?.emailSignIn(email: email, password: password)
        self.manager?.delegate = self
    }

    @IBAction func emailSignUpButton(_ sender: UIButton) {

        Alertift.alert(title: NSLocalizedString("agreemnt question", comment: ""), message: NSLocalizedString("agreemnt content", comment: ""))

            .action(.default("Agree")) { (_, _, _) in

                if let signUpPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpPage") as? SignUpPage {

                    self.addChild(signUpPage)
                    self.view.addSubview(signUpPage.view)
                    signUpPage.didMove(toParent: self)
                }
            }

            .action(.cancel("Disagree"))

            .show()

    }

    func setupButtonStyle(button: UIButton) {

        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 8
    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }
}

extension LoginPage: RegisterManagerDelegate {

    func didEmailSignIn(manager: RegisterManager) {

        self.manager?.presentToMainTabPage(viewController: self)
    }
}

extension LoginPage: UITextFieldDelegate {

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

        labelTextFieldContainer.transform = CGAffineTransform(translationX: 0, y: -120)
    }

    @objc func keyboardWillHide(_ notification: Notification) {

        labelTextFieldContainer.transform = CGAffineTransform.identity
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.view.endEditing(true)
    }
}
