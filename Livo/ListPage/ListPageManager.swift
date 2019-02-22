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
                    startTime: liveBroadcastStreamModel.snipped.scheduledStartTime,
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

            newLiveStreamInfos.sort(by: { $0.startTime.compare($1.startTime) == .orderedDescending })

            self.liveStreamInfos = newLiveStreamInfos

            DispatchQueue.main.async {

                self.delegate?.didFetchStreamInfo(manager: self, liveStreamInfos: self.liveStreamInfos)
            }
        })
    }

    func fetchMyUploadedVideos(uid: String, completionHandler: @escaping ([LiveStreamInfo]?) -> Void) {

        liveBroadcastStreamRef.queryOrdered(byChild: "userID").queryEqual(toValue: uid).observeSingleEvent(of: .value) { (snapshot) in

            var myVideoList: [LiveStreamInfo] = []

            if snapshot.childrenCount > 0 {

                for child in snapshot.children {

                    guard
                        let snapshot = child as? DataSnapshot,
                        let myVideo = LiveStreamInfo(snapshot: snapshot)
                    else {

                        DatabaseError.connectionError.alert(message: "Fail to get my video list")
                        return
                    }

                    myVideoList.append(myVideo)
                }

                completionHandler(myVideoList)

            } else {

                completionHandler(nil)
            }
        }
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

    func loadImageByClosure(imageURL: UIImage, indexPath: IndexPath, loadVideoType: LoadVideoType, completionHandler: (LiveStreamInfo, IndexPath) -> Void) {

        switch loadVideoType {

        case .insertVideo:

            completionHandler(liveStreamInfo, indexPath)

        case .deleteVideo:

            self.delegate?.didLoadimage(manager: self, liveStreamInfo: liveStreamInfo, indexPath: indexPath)
        }
    }

    func loadImage(imageURL: String, indexPath: Int) {

        DispatchQueue.global().async {

            guard let url = URL(string: imageURL) else { return }

            if let data = try? Data(contentsOf: url) {

                guard let image = UIImage(data: data) else { return }

                DispatchQueue.main.async {

                    if self.liveStreamInfos.count > 0 {

                        var liveStreamInfo = self.liveStreamInfos[indexPath]

                        let croppingImage = self.cropToBounds(image: image, width: 130, height: 180)

                        liveStreamInfo.image = croppingImage

                        self.delegate?.didLoadimage(manager: self, liveStreamInfo: liveStreamInfo, indexPath: indexPath)

                    }
                }
            }
        }
    }

    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - CGFloat(width)) / 2)
            posY = 0
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        let imageRef: CGImage = cgimage.cropping(to: rect)!

        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }

    func setUpLayout(spacing: CGFloat, cellInset: CGFloat) -> UICollectionViewFlowLayout {

        let layout = UICollectionViewFlowLayout()

        layout.setUpFlowLayout(spacing: spacing, cellInset: cellInset, itemWidth: 160, itemHeight: 270)

        layout.sectionInset = UIEdgeInsets(
            top: CGFloat(spacing),
            left: CGFloat(spacing),
            bottom: CGFloat(spacing),
            right: CGFloat(spacing))

        layout.minimumLineSpacing = CGFloat(cellInset)
        layout.minimumInteritemSpacing = CGFloat(cellInset)

        layout.estimatedItemSize = CGSize(width: CGFloat(160) ,
                                          height: CGFloat(270))

        return layout
    }
}
