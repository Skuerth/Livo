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

protocol LiveStreamManagerDelegate: class {

    func finishCreateLiveBroadcastStream(_ manager: LiveStreamManager)
}

class LiveStreamManager: YTLiveStreamingDelegate {

    let input = YTLiveStreaming()
    var liveBroadcastStreamModel: LiveBroadcastStreamModel?
    var userProfile: [String: String]?

    weak var delegate: LiveStreamManagerDelegate?

    func createLiveBroadcast(title: String, description: String) {

        let date = Date.init(timeIntervalSinceNow: 0)

        self.input.createBroadcast(title, description: description, startTime: date, completion: { (liveBroadcastStreamModel) in

            if let liveBroadcastStreamModel = liveBroadcastStreamModel {

                self.liveBroadcastStreamModel = liveBroadcastStreamModel

                self.delegate?.finishCreateLiveBroadcastStream(self)

            } else {

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

            }
        })
    }

    func stopLiveBroadcast() {

        if let liveBroadcastStreamModel = self.liveBroadcastStreamModel {

            self.input.completeBroadcast(liveBroadcastStreamModel, completion: { isCompleted in

            })
        } else {

        }
    }

    func saveLiveBroadcastStream() {

        let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        guard
            let liveBroadcastStreamModel = self.liveBroadcastStreamModel,
            let userProfile = self.userProfile,
            let userUID = userProfile["userUID"],
            let userName = userProfile["userName"],
            let imageURL = userProfile["imageURL"]
        else {
            return
        }

        let videoID = liveBroadcastStreamModel.id

        let liveStreamInfo = LiveStreamInfo(userID: userUID, userName: userName, imageURL: imageURL, title: liveBroadcastStreamModel.snipped.title, status: LiveStatus.live, videoID: videoID)

        liveBroadcastStreamRef.child(videoID).setValue(liveStreamInfo.toAnyObject())
    }

    // MARK: - YTLiveStreamingDelegate Method
    func didTransitionToLiveStatus() {

    }
}
