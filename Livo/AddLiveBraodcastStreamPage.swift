//
//  AddLiveBraodcastStreamPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/20.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YTLiveStreaming
import GoogleSignIn
import Firebase

class AddLiveBraodcastStreamPage: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    var liveStreamManager: LiveStreamManager?
    var userProfile: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.liveStreamManager = LiveStreamManager()
        self.liveStreamManager?.delegate = self

        GIDSignIn.sharedInstance()?.delegate = self
    }

    @IBAction func submitButton(_ sender: UIButton) {

        guard
            let title = self.titleTextField.text,
            let description = self.descriptionTextField.text
        else {
            return
        }

        let accessToken = GoogleOAuth2.sharedInstance.accessToken

        print("accessToken", accessToken)

        self.liveStreamManager?.createLiveBroadcast(title: title, description: description)
    }
}

extension AddLiveBraodcastStreamPage: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        guard let token = user.authentication.accessToken else { return }

        guard let userName = user.profile.name else { return }
        guard let userUID = user.userID else { return }
        guard let imageURL = user.profile.imageURL(withDimension: 150) else { return }

        let imageURLString = imageURL.absoluteString

        self.userProfile["userName"] = userName
        self.userProfile["userUID"] = userUID
        self.userProfile["imageURL"] = imageURLString
        self.liveStreamManager?.userProfile = self.userProfile

        GoogleOAuth2.sharedInstance.accessToken = token
    }
}

extension AddLiveBraodcastStreamPage: LiveStreamManagerDelegate {

    func finishCreateLiveBroadcastStream(_ manager: LiveStreamManager) {

        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)

        if let liveStreamingHostPage = mainStoryBoard.instantiateViewController(withIdentifier: "LiveStreamingHostPage") as? LiveStreamingHostPage {

            liveStreamingHostPage.liveStreamManager = manager

            manager.saveLiveBroadcastStream()

            DispatchQueue.main.async {

                self.present(liveStreamingHostPage, animated: true, completion: nil)
            }

        } else {

        }
    }
}

// Mark: - Firebase Method
extension AddLiveBraodcastStreamPage {

}




