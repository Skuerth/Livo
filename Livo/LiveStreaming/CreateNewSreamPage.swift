//
//  CreateNewSreamPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/20.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YTLiveStreaming
import GoogleSignIn
import Firebase

class CreateNewSreamPage: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var presentingView: UIView!

    var liveStreamManager: LiveStreamManager?
    var userProfile: [String: Any] = [:]
    var authCredential: AuthCredential?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.liveStreamManager = LiveStreamManager()
        self.liveStreamManager?.delegate = self

        self.presentingView.backgroundColor = .white
        self.presentingView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        GIDSignIn.sharedInstance()?.delegate = self
    }

    // MARK: - IBAction Method
    @IBAction func exitButton(_ sender: UIButton) {

        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    @IBAction func submitButton(_ sender: UIButton) {

        guard
            let title = self.titleTextField.text,
            let description = self.descriptionTextField.text
        else {
            return
        }

        self.liveStreamManager?.createLiveBroadcast(title: title, description: description)
    }
}

// MARK: - LiveStreamManagerDelegate Method
extension CreateNewSreamPage: LiveStreamManagerDelegate {

    func finishCreateLiveBroadcastStream(_ manager: LiveStreamManager) {

        if let liveBroadcastPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveBroadcastPage") as? LiveBroadcastPage {

            liveBroadcastPage.liveStreamManager = manager

            guard
                let uid = GIDSignIn.sharedInstance()?.currentUser.userID,
                let name = GIDSignIn.sharedInstance()?.currentUser.profile.name
            else {

                print("can't get google sign in informations")
                return
            }

            manager.saveLiveBroadcastStream(userUID: uid, userName: name)

            DispatchQueue.main.async {

                self.present(liveBroadcastPage, animated: true, completion: nil)
            }

        } else {

        }
    }
}

extension CreateNewSreamPage: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        GoogleOAuth2.sharedInstance.accessToken = user.authentication.accessToken
    }
}
