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

    func didEmailSignIn(manager: RegisterManager, userProfile: UserProfile)
}

class RegisterManager {

    weak var delegate: RegisterManagerDelegate?

    func emailSignIn(email: String, password: String) {

        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in

            guard
                let uid = result?.user.uid,
                let displayName = result?.user.displayName
                else {
                    return
            }

            let userProfile = UserProfile(name: displayName, email: email, password: password, emailLogInUID: uid)

            self.delegate?.didEmailSignIn(manager: self, userProfile: userProfile)

        })
    }

}
