//
//  RegisterManager.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase

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

                self.delegate?.didEmailSignIn(manager: self)
            }
        })
    }

}
