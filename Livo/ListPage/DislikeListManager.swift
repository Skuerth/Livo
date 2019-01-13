//
//  DislikeListManager.swift
//  Livo
//
//  Created by Skuerth on 2019/1/13.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation
import Firebase

protocol DislikeListManagerDelegate: class {

    func didFetchDislikeUsersList(_ manger: DislikeListManager, dislikeUsers: [String])
    func didFetchDislikeVideoList(_ manger: DislikeListManager, dislikeVideos: [String])
}

class DislikeListManager {

    weak var delegate: DislikeListManagerDelegate?

    func fetchDislikeUsersList(currentUID: String) {

        let dislikeUserRef = Database.database().reference(withPath: "user-prefer").child(currentUID).child("dislike-user")

        dislikeUserRef.queryOrderedByKey().observe(.value) { (dataSnapshot) in

            var dislikeUsers: [String] = []

            if dataSnapshot.childrenCount > 0 {

                for child in dataSnapshot.children {

                    guard
                        let snapshot = child as? DataSnapshot,
                        let dislikeUID = snapshot.value as? String
                        else {
                            return
                    }

                    dislikeUsers.append(dislikeUID)
                }

            } else {

            }

            self.delegate?.didFetchDislikeUsersList(self, dislikeUsers: dislikeUsers)
        }
    }

    func fetchDislikeVideoList(currentUID: String) {

        let dislikeVideosRef = Database.database().reference(withPath: "user-prefer").child(currentUID).child("videoID")

        dislikeVideosRef.queryOrderedByKey().observe(.value) { (dataSnapshot) in

            var dislikeVideos: [String] = []

            if dataSnapshot.childrenCount > 0 {

                for child in dataSnapshot.children {

                    guard
                        let snapshot = child as? DataSnapshot,
                        let dislikeVideoID = snapshot.value as? String
                    else {
                        return
                    }

                    dislikeVideos.append(dislikeVideoID)
                }
            } else {

            }

            self.delegate?.didFetchDislikeVideoList(self, dislikeVideos: dislikeVideos)
        }
    }

}
