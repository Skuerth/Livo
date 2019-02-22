//
//  userProfile.swift
//  Livo
//
//  Created by Skuerth on 2018/12/24.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation

class UserShareInstance {

    private static var share: UserShareInstance?

    static func sharedInstance() -> UserShareInstance {

        if share == nil {

            share = UserShareInstance()
        }
        return share!
    }

//    private var _currentUser: CurrentUser?

    var currentUser: CurrentUser?

//    var currentUser: CurrentUser?



    func createUser(name: String, email: String, emailLogInUID: String, photo: UIImage?) {

        let currentUser = CurrentUser(name: name, emailLogInUID: emailLogInUID, email: email, photo: nil)
        self.currentUser = currentUser
//        self.currentUser = currentUser
    }
}

struct LivoUser {

    var name: String
    var emailLogInUID: String
    var photo: UIImage?

    init(name: String, emailLogInUID: String, photo: UIImage?) {
        self.name = name
        self.emailLogInUID = emailLogInUID
        self.photo = photo
    }
}

struct CurrentUser {

    var name: String
    var emailLogInUID: String
    var email: String
    var photo: UIImage?

    init(name: String, emailLogInUID: String, email: String, photo: UIImage?) {
        self.name = name
        self.emailLogInUID = emailLogInUID
        self.email = email
        self.photo = photo
    }
}

class CurrentUserCreator {

    private static var shareInstance: CurrentUserCreator?

    static func createShareInstance() -> CurrentUserCreator {

        if shareInstance == nil {
            self.shareInstance = CurrentUserCreator()
        }

        return shareInstance!
    }

    var currentChatRoomSender: ChatrRoomSender?

    func currentGoogleSignInUser (uid: String, name: String, imageURL: String) {

        let currentChatRoomSender = ChatrRoomSender(uid: uid, name: name, imageURL: imageURL)

        self.currentChatRoomSender = currentChatRoomSender
    }
}

struct ChatrRoomSender {

    var uid: String
    var name: String
    var imageURL: String

    init(uid: String, name: String, imageURL: String) {
        self.uid = uid
        self.name = name
        self.imageURL = imageURL
    }
}

enum ProfileDataChangeType {
    
    case name
    case password
}
