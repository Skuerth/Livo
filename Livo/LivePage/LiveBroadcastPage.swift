//
//  LiveBroadcastPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/14.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import YTLiveStreaming
import LFLiveKit
import Firebase

class LiveBroadcastPage: UIViewController, LFLiveSessionDelegate {

    var liveStreamManager: LiveStreamManager?

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var lfView: LFLivePreview!
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.containerView.backgroundColor = .clear
        self.createLFSession()
        self.liveStreamManager?.startBroadcast(lfView: self.lfView)
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(true)

        DispatchQueue.main.async {

            self.lfView.prepareForUsing()
        }
    }
    @IBAction func onClickPublish(_ sender: UIButton) {

        guard
            let liveStreamManager = self.liveStreamManager,
            let id = liveStreamManager.liveBroadcastStreamModel?.id
        else {
            return

        }

        let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        startLiveButton.isSelected = false
        lfView.stopPublishing()
        liveStreamManager.stopLiveBroadcast()

        liveBroadcastStreamRef.queryOrderedByKey().queryEqual(toValue: id).observeSingleEvent(of: .value) { snapshot in

            snapshot.ref.child(id).updateChildValues([

                "status": LiveStatus.completed.rawValue
                ])
        }

        let main = UIStoryboard(name: "Main", bundle: nil)

        if
            let mainTabbarPage = main.instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage,
            let appDelegate = UIApplication.shared.delegate
        {

            dismiss(animated: true) {

                appDelegate.window??.rootViewController = mainTabbarPage
            }
        }
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {

    }

    func createLFSession() {

        var session: LFLiveSession = {

            let audioConfiguration = LFLiveAudioConfiguration.default()
            let videoConfiguration = LFLiveVideoConfiguration.defaultConfiguration(for: LFLiveVideoQuality.low3, outputImageOrientation: UIInterfaceOrientation.portrait)
            let session = LFLiveSession(audioConfiguration: audioConfiguration, videoConfiguration: videoConfiguration)

            session?.delegate = self
            session?.preView = self.lfView
            return session!
        }()
    }
}
