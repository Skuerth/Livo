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
    var liveStreamInfos: [LiveStreamInfo]?
    let cellInset: CGFloat = 15
    let spacing: CGFloat = 20

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
        self.manager?.fetchStreamInfo(status: LiveStatus.completed)
        self.manager?.delegate = self

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

        if let image = liveStreamInfos[indexPath.item].image {

            cell.photoView.image = image
        }

        return cell
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

        let indexPathForCell = IndexPath(row: indexPath, section: 0)
        self.collectionView.reloadItems(at: [indexPathForCell])
    }
}
