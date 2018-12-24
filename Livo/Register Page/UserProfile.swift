//
//  userProfile.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation

struct UserProfile {

    var name: String?
    var email: String
    var password: String?
    var emailLogInUID: String
    var photo: UIImage?


    init(name: String?, email: String, password: String?, emailLogInUID: String) {
        self.name = name
        self.email = email
        self.password = password
        self.emailLogInUID = emailLogInUID
    }
}
