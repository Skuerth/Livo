//
//  RegisterManager.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase
import Alertift

protocol RegisterManagerDelegate: class{

    func didEmailSignIn(manager: RegisterManager)
}

class RegisterManager {

    weak var delegate: RegisterManagerDelegate?

    func emailSignIn(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in

            if let error = error {

                AlertHelper.customerAlert.rawValue.alert(message: "\(error.localizedDescription)")
            }

            if result != nil {

                guard
                    let currentUser = Auth.auth().currentUser,
                    let email = currentUser.email,
                    let name = currentUser.displayName
                else {
                    return
                }
                let uid = currentUser.uid

                UserShareInstance.sharedInstance().createUser(name: name, email: email, emailLogInUID: uid, photo: nil)

                self.delegate?.didEmailSignIn(manager: self)
            }
        })
    }

    func presentToMainTabPage(viewController: UIViewController) {

        Alertift.alert(title: NSLocalizedString("agreemnt question", comment: ""), message: NSLocalizedString("agreemnt content", comment: ""))

//            .action(.cancel(NSLocalizedString("Disagree", comment: "")))

            .action(.cancel(NSLocalizedString("Disagree", comment: "")), handler: { (_, _, _) in

                do {

                    try Auth.auth().signOut()

                } catch let error {

                    AlertHelper.customerAlert.rawValue.alert(message: error.localizedDescription)
                }
            })

            .action(.default(NSLocalizedString("Agree", comment: ""))) { (_, _, _) in

                if let mainTabbarPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage {

                    viewController.present(mainTabbarPage, animated: true, completion: nil)
                }
            }

            .show()
    }
}
