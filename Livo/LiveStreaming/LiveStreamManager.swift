//
//  LiveStreamManager.swift
//  Livo
//
//  Created by Skuerth on 2018/12/20.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import YTLiveStreaming
import Firebase
import FirebaseDatabase
import GoogleSignIn

protocol LiveStreamManagerDelegate: class {

    func finishCreateLiveBroadcastStream(_ manager: LiveStreamManager)
    func didStartLiveBroadcast(_ manager: LiveStreamManager)
}

class LiveStreamManager {

    let input = YTLiveStreaming()
    var liveBroadcastStreamModel: LiveBroadcastStreamModel?
    var userProfile: [String: String]?

    weak var delegate: LiveStreamManagerDelegate?

    func createLiveBroadcast(title: String, description: String, viewController: CreateNewStreamPage) {

        let date = Date.init(timeIntervalSinceNow: 0)

        self.input.createBroadcast(title, description: description, startTime: date, completion: { (liveBroadcastStreamModel) in

            if let liveBroadcastStreamModel = liveBroadcastStreamModel {

                self.liveBroadcastStreamModel = liveBroadcastStreamModel

                self.delegate?.finishCreateLiveBroadcastStream(self)

            } else {

                if
                    let enableYouTubeStreamPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EnableYouTubeStreamPage") as? EnableYouTubeStreamPage,
                    let presentingViewController = viewController.createNewStreamPageSuperview

                {

                    viewController.willMove(toParent: nil)
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()

                    presentingViewController.addChild(enableYouTubeStreamPage)
                    presentingViewController.view.addSubview(enableYouTubeStreamPage.view)
                    enableYouTubeStreamPage.didMove(toParent: presentingViewController)
                }

                AlertHelper.customerAlert.rawValue.alert(message: "createBroadcast fail")
            }
        })
    }

    func startBroadcast(lfView: LFLivePreview) {

        guard let liveBroadcastStreamModel = self.liveBroadcastStreamModel else { return }

        self.input.startBroadcast(liveBroadcastStreamModel, delegate: self, completion: { streamName, streamUrl, scheduledStartTime in

            if let streamURL = streamUrl, let streamName = streamName {
                let streamUrl = "\(streamURL)/\(streamName)"

                lfView.startPublishing(withStreamURL: streamUrl)

            } else {

                LiveStreamError.getLiveStreamInfoError.alert(message: "can't star live broadcast")
            }
        })
    }

    func stopLiveBroadcast() {

        if let liveBroadcastStreamModel = self.liveBroadcastStreamModel {

            self.input.completeBroadcast(liveBroadcastStreamModel, completion: { isCompleted in

            })
        } else {

            LiveStreamError.getLiveStreamInfoError.alert(message: NSLocalizedString("can't stop live broadcast", comment: ""))
        }
    }

    func saveLiveBroadcastStream(userUID: String, userName: String) {

        let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        guard
            let liveBroadcastStreamModel = self.liveBroadcastStreamModel,
            let startTime = self.liveBroadcastStreamModel?.snipped.scheduledStartTime.dateConvertToString(),
            let imageURL = self.liveBroadcastStreamModel?.snipped.thumbnails.medium.url,
            let description = self.liveBroadcastStreamModel?.snipped.description
        else {

            LiveStreamError.getLiveStreamInfoError.alert()
            return
        }

        let videoID = liveBroadcastStreamModel.id

        let liveStreamInfo = LiveStreamInfo(userID: userUID, userName: userName, imageURL: imageURL, title: liveBroadcastStreamModel.snipped.title, status: LiveStatus.live, videoID: videoID, startTime: startTime.stringConvertToDate(), description: description)

        liveBroadcastStreamRef.child(videoID).setValue(liveStreamInfo.toAnyObject())
    }
}

extension LiveStreamManager: LiveStreamTransitioning {

    func didTransitionToLiveStatus() {

        self.delegate?.didStartLiveBroadcast(self)
    }
}
