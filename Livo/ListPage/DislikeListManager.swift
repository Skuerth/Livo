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
    func finishPresentedDislikePage(_ manger: DislikeListManager, button: UIButton)
}

class DislikeListManager {

    var popViewController: UIViewController?
    var popoverPresentationController: UIPopoverPresentationController?
    var dislikeIndexPath: IndexPath?
    var liveStreamInfos: [LiveStreamInfo]?

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

    @objc func didPressDislikeButton(button: UIButton, viewController: UIViewController) {

        let buttonColor: UIColor = UIColor.init(red: 10, green: 96, blue: 254)

        let dislikeVideoLabel = createLabel(title: "Hide this video", fontSize: 14)
        let dislikeVideoButton = createButton(title: "Yes", fontSize: 14, buttonColor: buttonColor)
        setupButtonArttribute(button: dislikeVideoButton, buttonColor: buttonColor)

        dislikeVideoButton.addTarget(self, action: #selector(hideVideo), for: .touchUpInside)

        let dislikeUserLabel = createLabel(title: "Hide all videos of this broadcaster", fontSize: 14)
        let dislikeUserButton = createButton(title: "Yes", fontSize: 14, buttonColor: buttonColor)
        setupButtonArttribute(button: dislikeUserButton, buttonColor: buttonColor)
        dislikeUserButton.addTarget(self, action: #selector(hideAllVideoOfUser(sender:)), for: .touchUpInside)

        let aPopViewController = UIViewController()
        aPopViewController.modalPresentationStyle = .popover
        aPopViewController.preferredContentSize = CGSize(width: 250, height: 120)

        aPopViewController.view.addSubview(dislikeVideoLabel)
        aPopViewController.view.addSubview(dislikeVideoButton)
        aPopViewController.view.addSubview(dislikeUserLabel)
        aPopViewController.view.addSubview(dislikeUserButton)
//
        popoverPresentationController = aPopViewController.popoverPresentationController
        popoverPresentationController?.sourceView = button
        popoverPresentationController?.sourceRect = button.bounds
        popoverPresentationController?.permittedArrowDirections = .down

//        vc.present(aPopViewController, animated: true, completion: nil)

        dislikeVideoLabel.translatesAutoresizingMaskIntoConstraints = false
        dislikeVideoButton.translatesAutoresizingMaskIntoConstraints = false
        dislikeUserLabel.translatesAutoresizingMaskIntoConstraints = false
        dislikeUserButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            dislikeVideoLabel.topAnchor.constraint(equalTo: aPopViewController.view.topAnchor, constant: 15),
            dislikeVideoLabel.leadingAnchor.constraint(equalTo: aPopViewController.view.leadingAnchor, constant: 15),

            dislikeVideoButton.topAnchor.constraint(equalTo: dislikeVideoLabel.bottomAnchor, constant: 5),
            dislikeVideoButton.leadingAnchor.constraint(equalTo: dislikeVideoLabel.leadingAnchor, constant: 0),
            dislikeVideoButton.heightAnchor.constraint(equalToConstant: 20),

            dislikeUserLabel.topAnchor.constraint(equalTo: dislikeVideoButton.bottomAnchor, constant: 10),
            dislikeUserLabel.leadingAnchor.constraint(equalTo: aPopViewController.view.leadingAnchor, constant: 15),

            dislikeUserButton.topAnchor.constraint(equalTo: dislikeUserLabel.bottomAnchor, constant: 5),
            dislikeUserButton.leadingAnchor.constraint(equalTo: dislikeUserLabel.leadingAnchor, constant: 0),
            dislikeUserButton.heightAnchor.constraint(equalToConstant: 20)
            ])

        self.popViewController = aPopViewController

        self.delegate?.finishPresentedDislikePage(self, button: button)

    }

    @objc func hideVideo(sender: UIButton) {

        guard
            let indexPath = self.dislikeIndexPath,
            let liveStreamInfos = self.liveStreamInfos,
            let currentUser = UserShareInstance.sharedInstance().currentUser
            else {
                return
        }

        let videoID = liveStreamInfos[indexPath.row].videoID
        let currentUID = currentUser.emailLogInUID

        let userPreferRef = Database.database().reference(withPath: "user-prefer")
        let videoRef = userPreferRef.child(currentUID).child("videoID").childByAutoId()

        videoRef.setValue(videoID)

        popViewController?.dismiss(animated: true, completion: nil)
    }

    @objc func hideAllVideoOfUser(sender: UIButton) {

        guard
            let indexPath = self.dislikeIndexPath,
            let liveStreamInfos = self.liveStreamInfos,
            let currentUser = UserShareInstance.sharedInstance().currentUser
            else {
                return
        }

        let currentUID = currentUser.emailLogInUID

        let dislikeUserID = liveStreamInfos[indexPath.row].userID

        let userPreferRef = Database.database().reference(withPath: "user-prefer")
        let dislikeUserRef = userPreferRef.child(currentUID).child("dislike-user").childByAutoId()

        dislikeUserRef.setValue(dislikeUserID)

        popViewController?.dismiss(animated: true, completion: nil)
    }

    func createLabel(title: String, fontSize: CGFloat) -> UILabel {

        let label = UILabel()
        label.text = title
        label.font = label.font.withSize(14)
        label.textColor = UIColor.gray

        return label
    }

    func createButton(title: String, fontSize: CGFloat, buttonColor: UIColor) -> UIButton {

        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(buttonColor, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(fontSize)

        return button
    }

    func setupButtonArttribute(button: UIButton, buttonColor: UIColor) {

        button.layer.borderColor = buttonColor.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
    }
}
