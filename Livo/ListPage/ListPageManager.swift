//
//  ListPageManager.swift
//  Livo
//
//  Created by Skuerth on 2018/12/23.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import Firebase
import YTLiveStreaming

protocol ListPageManagerDelegate: class {

    func didFetchStreamInfo(manager: ListPageManager, liveStreamInfos: [LiveStreamInfo])
    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int)
    func didFetchAllVideo(_ manager: ListPageManager, liveStreamInfos: [LiveStreamInfo])
}

class ListPageManager {

    let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")
    var liveStreamInfos: [LiveStreamInfo] = []

    weak var delegate: ListPageManagerDelegate?
    var input = YTLiveStreaming()

    // MARK: Live Sreaming Method
    func fetchAllVideo() {

        guard
            let name = Auth.auth().currentUser?.displayName,
            let uid = Auth.auth().currentUser?.uid
        else {

            UserInfoError.authorizationError.alert(message: "please resign in again")
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
                    startTime: liveBroadcastStreamModel.snipped.scheduledStartTime.dateConvertToString(),
                    description: liveBroadcastStreamModel.snipped.description
                    )

                newLiveStreamInfos.append(liveStreamInfo)
            }

            self.liveStreamInfos = newLiveStreamInfos
            self.delegate?.didFetchAllVideo(self, liveStreamInfos: newLiveStreamInfos)
        }
    }

    // MARK: Firebase Method
    func fetchStreamInfo(status: LiveStatus) {

        var statusString = ""

        switch status {
        case .live:
            statusString = LiveStatus.live.rawValue

        case .completed:
            statusString = LiveStatus.completed.rawValue
        }

        liveBroadcastStreamRef.queryOrdered(byChild: "status").queryEqual(toValue: statusString).observe(.value, with: { snapshot in

            var newLiveStreamInfos: [LiveStreamInfo] = []

            print("snapshot.childrenCount", snapshot.childrenCount)

            if snapshot.childrenCount > 0 {

                for child in snapshot.children {

                    guard
                        let snapshot = child as? DataSnapshot,
                        let liveStreamInfo = LiveStreamInfo(snapshot: snapshot)
                        else {

                            DatabaseError.connectionError.alert(message: "fail to get \(statusString) broadcast")
                            return
                    }

                    newLiveStreamInfos.append(liveStreamInfo)
                }
            }

            self.liveStreamInfos = newLiveStreamInfos

            DispatchQueue.main.async {

                self.delegate?.didFetchStreamInfo(manager: self, liveStreamInfos: self.liveStreamInfos)
            }
        })
    }

    func sendSelectedLiveStreamToFirebase(uid: String, name: String, index: Int) {

        if (liveStreamInfos.count - 1) >= index {

            let liveStreamInfo = liveStreamInfos[index]

            let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

            let videoID = liveStreamInfo.videoID

            liveBroadcastStreamRef.queryOrderedByKey().queryEqual(toValue: videoID).observeSingleEvent(of: .value) { dataSnapshot in

                if !dataSnapshot.exists() {

                    liveBroadcastStreamRef.child(videoID).setValue(liveStreamInfo.toAnyObject())
                }
            }
        }
    }

    func loadImage(imageURL: String, indexPath: Int) {

        DispatchQueue.global().async {

            guard let url = URL(string: imageURL) else { return }

            if let data = try? Data(contentsOf: url) {

                guard let image = UIImage(data: data) else { return }

                DispatchQueue.main.async {

                    var liveStreamInfo = self.liveStreamInfos[indexPath]

                    liveStreamInfo.image = image
                    self.delegate?.didLoadimage(manager: self, liveStreamInfo: liveStreamInfo, indexPath: indexPath)
                }
            }
        }
    }
}
