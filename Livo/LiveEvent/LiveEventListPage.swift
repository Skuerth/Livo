//
//  LiveEventListPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/18.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YTLiveStreaming
import Firebase

class LiveEventListPage: UICollectionViewController {

    var liveBroadcastStreamRef: DatabaseReference?
    var liveStreamInfos: [LiveStreamInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        self.liveBroadcastStreamRef?.queryOrdered(byChild: "status").queryEqual(toValue: LiveStatus.live.rawValue).observe(.value, with: { snapshot in

            var newLiveStreamInfos: [LiveStreamInfo] = []

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
        })

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        return cell
    }
}
