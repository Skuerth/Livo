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
import GoogleSignIn

class LiveEventListPage: UICollectionViewController, GIDSignInUIDelegate {

    var dislikeManager: DislikeListManager?
    var currentUID: String?
    var dislikeUsers: [String]?
    var dislikeVideos: [String]?
    var dislikeIndexPath: IndexPath?

    var liveBroadcastStreamRef: DatabaseReference?
    var liveStreamInfos: [LiveStreamInfo]?
    var manager: ListPageManager?


    let reuseIdentifier = "VideoListCollectionCell"

    let spacing: CGFloat = 20
    let cellInset: CGFloat = 15

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("LiveVideo", comment: "")

        self.manager = ListPageManager()
        self.manager?.delegate = self

        self.dislikeManager = DislikeListManager()
        self.dislikeManager?.delegate = self

        if let uid = UserShareInstance.sharedInstance().currentUser?.emailLogInUID {

            self.currentUID = uid

            self.dislikeManager?.fetchDislikeUsersList(currentUID: uid)
        }

        self.liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        self.collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        guard let layout = self.manager?.setUpLayout(spacing: spacing, cellInset: cellInset) else { return }

        self.collectionView.collectionViewLayout = layout

//        self.manager?.fetchStreamInfo(status: LiveStatus.live)
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - IBAction Method
    @IBAction func createNewLiveBroadcast(_ sender: UIBarButtonItem) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.scopes = [
            "https://www.googleapis.com/auth/youtube",
            "https://www.googleapis.com/auth/youtube.force-ssl"]
        GIDSignIn.sharedInstance()?.signIn()

        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let createNewSreamPage = mainStoryBoard.instantiateViewController(withIdentifier: "CreateNewSreamPage") as? CreateNewSreamPage {

            addChild(createNewSreamPage)
            self.view.addSubview(createNewSreamPage.view)
            createNewSreamPage.didMove(toParent: self)
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if liveStreamInfos?.count == 0 {

            AlertHelper.customerAlert.rawValue.alert(message: "There is no Live Stream")
        }
        return self.liveStreamInfos?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let clientWatchPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientWatchPage") as? ClientWatchPage,
            let liveStreamInfos = self.liveStreamInfos {

            clientWatchPage.videoID = liveStreamInfos[indexPath.item].videoID

            self.navigationController?.pushViewController(clientWatchPage, animated: true)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? VideoListCollectionCell
        else {
            return UICollectionViewCell()
        }

        guard let liveStreamInfos = self.liveStreamInfos else { return cell }

        cell.titleLabel.text = liveStreamInfos[indexPath.row].title
        cell.nameLabel.text = liveStreamInfos[indexPath.row].userName
        cell.dateLabel.text = liveStreamInfos[indexPath.row].startTime.dateConvertToString().longDateStringConvertToshort()

        cell.dislikeButton.addTarget(self, action: #selector(didPressDislikeButton(button:)), for: .touchUpInside)

        if let image = liveStreamInfos[indexPath.item].image {

            cell.photoView.image = image
        }

        return cell
    }
}

extension LiveEventListPage: ListPageManagerDelegate {

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
//
//
//
//        self.liveStreamInfos = liveStreamInfos
//        self.collectionView.reloadData()
//
//        var indexPath = 0
//
//        for liveStreamInfo in liveStreamInfos {
//
//            manager.loadImage(imageURL: liveStreamInfo.imageURL, indexPath: indexPath)
//
//            indexPath += 1
//        }
    }

    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int) {

        self.liveStreamInfos?[indexPath] = liveStreamInfo

        DispatchQueue.main.async {

            let indexPathForItem = IndexPath(item: indexPath, section: 0)
            self.collectionView.reloadItems(at: [indexPathForItem])
        }
    }

    @objc func didPressDislikeButton(button: UIButton) {

        dislikeManager?.liveStreamInfos = self.liveStreamInfos

        dislikeManager?.didPressDislikeButton(button: button, viewController: self)
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

extension LiveEventListPage: DislikeListManagerDelegate {

    func didFetchDislikeUsersList(_ manger: DislikeListManager, dislikeUsers: [String]) {

        self.dislikeUsers = dislikeUsers

        guard let uid = self.currentUID else { return }

        self.dislikeManager?.fetchDislikeVideoList(currentUID: uid)
    }

    func didFetchDislikeVideoList(_ manger: DislikeListManager, dislikeVideos: [String]) {

        self.dislikeVideos = dislikeVideos

        self.manager?.fetchStreamInfo(status: LiveStatus.live)
    }

    func finishPresentedDislikePage(_ manger: DislikeListManager, button: UIButton) {

        let point: CGPoint = button.convert(.zero, to: self.collectionView)

        guard
            let indexPath = self.collectionView.indexPathForItem(at: point),
            let dislikeManager = self.dislikeManager,
            let popViewController = dislikeManager.popViewController
            else {
                return
        }

        dislikeManager.popoverPresentationController?.delegate = self
        self.present(popViewController, animated: true, completion: nil)

        dislikeManager.dislikeIndexPath = indexPath

    }
}

extension LiveEventListPage: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {

        return .none
    }
}
