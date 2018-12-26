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

class GoogleSignInUserCreator {

    private static var shareInstance: GoogleSignInUserCreator?

    static func createShareInstance() -> GoogleSignInUserCreator {

        if shareInstance == nil {
            self.shareInstance = GoogleSignInUserCreator()
        }

        return shareInstance!
    }

    var googleSignInUser: GoogleSignInUser?

    func currentGoogleSignInUser (uid: String, name: String, imageURL: String) {

        let googleSignInUser = GoogleSignInUser(uid: uid, name: name, imageURL: imageURL)

        self.googleSignInUser = googleSignInUser
    }
}

struct GoogleSignInUser {

    var uid: String
    var name: String
    var imageURL: String

    init(uid: String, name: String, imageURL: String) {
        self.uid = uid
        self.name = name
        self.imageURL = imageURL
    }
}
