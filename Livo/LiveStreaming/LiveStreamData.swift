//
//  LiveStreamData.swift
//  Livo
//
//  Created by Skuerth on 2018/12/21.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import Firebase

struct LiveStreamInfo {

    var userID: String
    var userName: String
    var imageURL: String
    var image: UIImage?
    var title: String
    var status: LiveStatus
    var videoID: String
    var startTime: String

    init(userID: String, userName: String, imageURL: String, title: String, status: LiveStatus, videoID: String, startTime: String) {

        self.userID = userID
        self.userName = userName
        self.imageURL = imageURL
        self.title = title
        self.status = status
        self.videoID = videoID
        self.startTime = startTime
    }

    init?(snapshot: DataSnapshot) {

        guard
            let value = snapshot.value as? [String: Any],
            let userID = value["userID"] as? String,
            let userName = value["userName"] as? String,
            let title = value["title"] as? String,
            let imageURL = value["imageURL"] as? String,
            let status = value["status"] as? String,
            let startTime = value["startTime"] as? String
        else {
            return nil
        }

        self.userID = userID
        self.userName = userName
        self.title = title
        self.imageURL = imageURL
        self.videoID = snapshot.key
        self.startTime = startTime

        if status == "live" {

            self.status = LiveStatus.live

        } else {

            self.status = LiveStatus.completed
        }
    }

    func toAnyObject() -> Any {

        return [
                "userID": self.userID,
                "userName": self.userName,
                "imageURL": self.imageURL,
                "title": self.title,
                "status": self.status.rawValue,
                "videoID": self.videoID,
                "startTime": self.startTime
        ]
    }
}

enum LiveStatus: String {

    case live
    case completed
}
