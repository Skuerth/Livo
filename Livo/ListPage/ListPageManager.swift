//
//  ListPageManager.swift
//  Livo
//
//  Created by Skuerth on 2018/12/23.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import Firebase

protocol ListPageManagerDelegate: class {

    func didFetchStreamInfo(manager: ListPageManager, liveStreamInfos: [LiveStreamInfo])
    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int)
}

class ListPageManager {

    let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")
    var liveStreamInfos: [LiveStreamInfo] = []

    weak var delegate: ListPageManagerDelegate?

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
