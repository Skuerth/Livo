//
//  VideoListCollectionPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/5.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit
import GoogleSignIn
import YTLiveStreaming
import Firebase

private let reuseIdentifier = "VideoListCollectionCell"

class VideoListCollectionPage: UICollectionViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    var manager: ListPageManager?
    var dislikeManager: DislikeListManager?
    var currentUID: String?
    var dislikeUsers: [String]?
    var dislikeVideos: [String]?

    var liveStreamInfos: [LiveStreamInfo]?
    let cellInset: CGFloat = 15
    let spacing: CGFloat = 20
    var dislikeIndexPath: IndexPath?

    var popViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        button.setImage(UIImage(named: "profile-icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = UIColor.white
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTouchProfileButton), for: .touchUpInside)

        self.navigationItem.title = NSLocalizedString("VideoList", comment: "")

        let barButton = UIBarButtonItem(customView: button)

        let currWidth = barButton.customView?.widthAnchor.constraint(equalToConstant: 25)
        currWidth?.isActive = true
        let currHeight = barButton.customView?.heightAnchor.constraint(equalToConstant: 25)
        currHeight?.isActive = true

        self.navigationItem.rightBarButtonItems?.insert(barButton, at: 0)

        self.manager = ListPageManager()
        self.dislikeManager = DislikeListManager()
        self.manager?.delegate = self
        self.dislikeManager?.delegate = self

        if let uid = UserShareInstance.sharedInstance().currentUser?.emailLogInUID {

            self.currentUID = uid

            self.dislikeManager?.fetchDislikeUsersList(currentUID: uid)
        }

        self.collectionView!.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        guard let layout = self.manager?.setUpLayout(spacing: self.spacing, cellInset: self.cellInset) else { return }

        self.collectionView.collectionViewLayout = layout
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = false
    }

    @objc func didTouchProfileButton() {

        guard let profilePage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfilePage") as? ProfilePage else { return }

        self.navigationController?.pushViewController(profilePage, animated: true)
    }

    @IBAction func insertVideo(_ sender: UIBarButtonItem) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.scopes.append("https://www.googleapis.com/auth/youtube")
        GIDSignIn.sharedInstance()?.scopes.append("https://www.googleapis.com/auth/youtube.readonly")
        GIDSignIn.sharedInstance()?.signIn()
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        if user != nil {

            guard
                let token = user.authentication.accessToken
                else {
                    return
            }

            GoogleOAuth2.sharedInstance.accessToken = token

            guard let insertVideoPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InsertVideoPage") as? InsertVideoPage else { return }

            insertVideoPage.preScreenShot = takeScreenshot()

            self.navigationController?.pushViewController(insertVideoPage, animated: true)
        } else {

            UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
        }
    }

    func takeScreenshot() -> UIImage? {

        var screenshotImage: UIImage?
        let layer = view.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in: context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.liveStreamInfos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VideoListCollectionCell
        else {
            return UICollectionViewCell()
        }

        guard let liveStreamInfos = liveStreamInfos else { return  cell }

        cell.titleLabel.text = liveStreamInfos[indexPath.row].title
        cell.nameLabel.text = liveStreamInfos[indexPath.row].userName
        cell.dateLabel.text = liveStreamInfos[indexPath.row].startTime.dateConvertToString().longDateStringConvertToshort()
        cell.dislikeButton.addTarget(self, action: #selector(didPressDislikeButton), for: .touchUpInside)

        if let image = liveStreamInfos[indexPath.item].image {

            cell.photoView.image = image
        }

        return cell
    }

    @objc func didPressDislikeButton(button: UIButton) {

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

        let popoverPresentationController = aPopViewController.popoverPresentationController
        popoverPresentationController?.sourceView = button
        popoverPresentationController?.sourceRect = button.bounds
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController?.delegate = self

        present(aPopViewController, animated: true, completion: nil)

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
            dislikeUserButton.heightAnchor.constraint(equalToConstant: 20),
        ])

        self.popViewController = aPopViewController

        let point: CGPoint = button.convert(.zero, to: self.collectionView)

        guard
            let indexPath = collectionView.indexPathForItem(at: point),
            let liveStreamInfos = self.liveStreamInfos
        else {
            return
        }

        dislikeIndexPath = indexPath
        print("indexPath",indexPath)

        if let currentUser = UserShareInstance.sharedInstance().currentUser {

            let currentUID = currentUser.emailLogInUID
        }
    }

    @objc func hideVideo(sender: UIButton) {

        guard
            let indexPath = self.dislikeIndexPath,
            let liveStreamInfos = liveStreamInfos,
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
            let liveStreamInfos = liveStreamInfos,
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let clientWatchPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientWatchPage") as? ClientWatchPage,
            let liveStreamInfos = self.liveStreamInfos {

            clientWatchPage.videoID = liveStreamInfos[indexPath.row].videoID

            self.navigationController?.pushViewController(clientWatchPage, animated: true)
        }
    }
}

extension VideoListCollectionPage: ListPageManagerDelegate {

    func didFetchAllVideo(_ manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

    }

    func didFetchStreamInfo(manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

        let withoutDislikeUsersInfos =  hideDislikeUsers(liveStreamInfos: liveStreamInfos)

        let withoutDislikeListInfos = hideDislikeVideos(liveStreamInfos: withoutDislikeUsersInfos)

        self.liveStreamInfos = withoutDislikeListInfos

        self.collectionView.reloadData()

        var indexPath = 0

        self.manager?.liveStreamInfos = withoutDislikeListInfos

        for liveStreamInfo in withoutDislikeListInfos {

            manager.loadImage(imageURL: liveStreamInfo.imageURL, indexPath: indexPath)

            indexPath += 1
        }
    }

    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int) {

        guard var liveStreamInfos = liveStreamInfos else { return }

        if liveStreamInfos.count > 0 {

            self.liveStreamInfos?[indexPath] = liveStreamInfo

//            self.liveStreamInfos = liveStreamInfos

            DispatchQueue.main.async {

                let indexPathForCell = IndexPath(row: indexPath, section: 0)
                self.collectionView.reloadItems(at: [indexPathForCell])
            }
        }
    }

    func hideDislikeUsers(liveStreamInfos: [LiveStreamInfo]) -> [LiveStreamInfo] {

        guard let dislikeUsers = dislikeUsers else { return liveStreamInfos}

        if dislikeUsers.count > 0 {

            var newLiveStreamInfo = [LiveStreamInfo]()

            newLiveStreamInfo = liveStreamInfos

            for userID in dislikeUsers {

                newLiveStreamInfo = newLiveStreamInfo.filter() { $0.userID != userID}
            }

            return newLiveStreamInfo

        } else {

            return liveStreamInfos
        }
    }

    func hideDislikeVideos(liveStreamInfos: [LiveStreamInfo]) -> [LiveStreamInfo] {

        guard let dislikeVideos = dislikeVideos else { return liveStreamInfos}

        if dislikeVideos.count > 0 {

            var newLiveStreamInfo = [LiveStreamInfo]()

            newLiveStreamInfo = liveStreamInfos

            for videoID in dislikeVideos {

                newLiveStreamInfo = newLiveStreamInfo.filter() { $0.videoID != videoID}
            }

            return newLiveStreamInfo

        } else {

            return liveStreamInfos
        }
    }

}

extension VideoListCollectionPage: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {

        return .none
    }
}

extension VideoListCollectionPage: DislikeListManagerDelegate {

    func didFetchDislikeUsersList(_ manger: DislikeListManager, dislikeUsers: [String]) {

        self.dislikeUsers = dislikeUsers

        guard let uid = self.currentUID else { return }

        self.dislikeManager?.fetchDislikeVideoList(currentUID: uid)
    }

    func didFetchDislikeVideoList(_ manger: DislikeListManager, dislikeVideos: [String]) {

        self.dislikeVideos = dislikeVideos

        self.manager?.fetchStreamInfo(status: LiveStatus.completed)
    }
}
