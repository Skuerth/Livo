//
//  VideoManager.swift
//  Livo
//
//  Created by Skuerth on 2018/12/26.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import YTLiveStreaming
import Firebase

protocol VideoManagerDelegate: class {

    func didFetchAllVideo(_ manager: VideoManager, liveStreamInfos: [LiveStreamInfo])
}

class VideoManager {

    var input = YTLiveStreaming()
    var liveStreamInfos: [LiveStreamInfo] = []
    var delegate: VideoManagerDelegate?

    func fetchAllVideo() {

        guard
            let name = Auth.auth().currentUser?.displayName,
            let uid = Auth.auth().currentUser?.uid
        else {
            return
        }

        self.input.getCompletedBroadcasts { liveBroadcastStreamModels in

            guard let liveBroadcastStreamModels = liveBroadcastStreamModels else { return }

            var newLiveStreamInfos: [LiveStreamInfo] = []

            for liveBroadcastStreamModel in liveBroadcastStreamModels {

                let liveStreamInfo = LiveStreamInfo(
                    userID: uid,
                    userName: name,
                    imageURL: liveBroadcastStreamModel.snipped.thumbnails.medium.url,
                    title: liveBroadcastStreamModel.snipped.title,
                    status: LiveStatus.completed,
                    videoID: liveBroadcastStreamModel.id,
                    startTime: liveBroadcastStreamModel.snipped.scheduledStartTime.dateConvertToString())

                newLiveStreamInfos.append(liveStreamInfo)
            }

            self.liveStreamInfos = newLiveStreamInfos
            self.delegate?.didFetchAllVideo(self, liveStreamInfos: newLiveStreamInfos)
        }
    }
}
