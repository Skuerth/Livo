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
    var authCredential: AuthCredential?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.liveStreamManager = LiveStreamManager()
        self.liveStreamManager?.delegate = self

//        GIDSignIn.sharedInstance()?.delegate = self
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
