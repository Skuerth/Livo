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

        self.liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        self.collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

//        let layout = UICollectionViewFlowLayout()
//
//        layout.sectionInset = UIEdgeInsets(
//                                        top: CGFloat(spaceing),
//                                        left: CGFloat(spaceing),
//                                        bottom: CGFloat(spaceing),
//                                        right: CGFloat(spaceing))
//
//        layout.minimumLineSpacing = CGFloat(cellInset)
//        layout.minimumInteritemSpacing = CGFloat(cellInset)
//
//        layout.estimatedItemSize = CGSize(width: CGFloat(157) ,
//                                          height: CGFloat(151))

        guard let layout = self.manager?.setUpLayout(spacing: spacing, cellInset: cellInset) else { return }

        self.collectionView.collectionViewLayout = layout

        self.manager?.fetchStreamInfo(status: LiveStatus.live)
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

        self.liveStreamInfos = liveStreamInfos
        self.collectionView.reloadData()

        var indexPath = 0

        for liveStreamInfo in liveStreamInfos {

            manager.loadImage(imageURL: liveStreamInfo.imageURL, indexPath: indexPath)

            indexPath += 1
        }
    }

    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int) {

        self.liveStreamInfos?[indexPath] = liveStreamInfo

        let indexPathForItem = IndexPath(item: indexPath, section: 0)
        self.collectionView.reloadItems(at: [indexPathForItem])
    }
}
