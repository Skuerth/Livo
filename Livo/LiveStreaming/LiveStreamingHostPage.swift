//
//  LiveStreamingHostPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/14.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import YTLiveStreaming
import LFLiveKit

class LiveStreamingHostPage: UIViewController, LFLiveSessionDelegate {

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
    @IBAction func getID(_ sender: UIButton) {

    }

    @IBAction func onClickPublish(_ sender: UIButton) {

            startLiveButton.isSelected = false
//            startLiveButton.setTitle("Stop live broadcast", for: .normal)
            lfView.stopPublishing()
            self.liveStreamManager?.stopLiveBroadcast()
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
