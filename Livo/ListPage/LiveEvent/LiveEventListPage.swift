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

class LiveEventListPage: UICollectionViewController {

    let liveEventListCellID = "LiveEventListCell"

    var liveBroadcastStreamRef: DatabaseReference?
    var liveStreamInfos: [LiveStreamInfo]?
    var listPageManager: ListPageManager?

    let spaceing: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        self.listPageManager = ListPageManager()
        self.listPageManager?.delegate = self

        self.liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        self.collectionView.register(UINib(nibName: liveEventListCellID, bundle: nil), forCellWithReuseIdentifier: liveEventListCellID)

        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(
                                        top: CGFloat(spaceing),
                                        left: CGFloat(spaceing),
                                        bottom: CGFloat(spaceing),
                                        right: CGFloat(spaceing))
        layout.minimumLineSpacing = CGFloat(spaceing)
        layout.minimumInteritemSpacing = CGFloat(27)

        layout.estimatedItemSize = CGSize(width: CGFloat(154) ,
                                          height: CGFloat(160))

        self.collectionView.collectionViewLayout = layout

        self.listPageManager?.fetchStreamInfo(status: LiveStatus.live)

    }

    @IBAction func googleSignOut(_ sender: UIBarButtonItem) {

        GIDSignIn.sharedInstance()?.signOut()

        guard let loginPage = self.storyboard?.instantiateViewController(withIdentifier: "LoginPage") as? LoginPage else { return }

        guard let appDelegate = UIApplication.shared.delegate else { return }
        appDelegate.window??.rootViewController = loginPage
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: liveEventListCellID, for: indexPath) as? LiveEventListCell
        else {
            return UICollectionViewCell()
        }

        guard let liveStreamInfos = self.liveStreamInfos else { return cell }

        cell.broadcastTitle.text = liveStreamInfos[indexPath.row].title
        cell.broadcasterName.text = liveStreamInfos[indexPath.row].userName

        if let image = liveStreamInfos[indexPath.item].image {

            cell.broadcastImage.image = image
        }

        return cell
    }
}

extension LiveEventListPage: ListPageManagerDelegate {

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