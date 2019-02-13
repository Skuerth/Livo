//
//  VideoListPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/25.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import GoogleSignIn
import YTLiveStreaming
import Firebase

class VideoListPage: UITableViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    var manager: ListPageManager?
    var liveStreamInfos: [LiveStreamInfo]?

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

        tableView.estimatedRowHeight = 120
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 75, bottom: 0, right: 0)

        tableView.rowHeight = UITableView.automaticDimension

        self.tableView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellReuseIdentifier: "VideoListCell")

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

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if liveStreamInfos?.count == 0 {

            AlertHelper.customerAlert.rawValue.alert(message: "There is no video")
        }

        return liveStreamInfos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell", for: indexPath) as? VideoListCell else {

            return UITableViewCell()
        }

        guard let liveStreamInfos = liveStreamInfos else { return  cell }

        print("liveStreamInfos[indexPath.row]", liveStreamInfos[indexPath.row])
        cell.titleLabel.text = liveStreamInfos[indexPath.row].title
        cell.nameLabel.text = liveStreamInfos[indexPath.row].userName
        cell.dateLabel.text = liveStreamInfos[indexPath.row].startTime.dateConvertToString().longDateStringConvertToshort()
        cell.selectionStyle = .none

        if let image = liveStreamInfos[indexPath.item].image {

            cell.photoView.image = image
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let clientWatchPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientWatchPage") as? ClientWatchPage,
            let liveStreamInfos = self.liveStreamInfos {

            clientWatchPage.videoID = liveStreamInfos[indexPath.row].videoID

            self.navigationController?.pushViewController(clientWatchPage, animated: true)
        }
    }
}

extension VideoListPage: ListPageManagerDelegate {

    func didFetchAllVideo(_ manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

    }

    func didFetchStreamInfo(manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

        self.liveStreamInfos = liveStreamInfos
        self.tableView.reloadData()

        var indexPath = 0

        for liveStreamInfo in liveStreamInfos {

            manager.loadImage(imageURL: liveStreamInfo.imageURL, indexPath: indexPath)

            indexPath += 1
        }
    }

    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int) {

        self.liveStreamInfos?[indexPath] = liveStreamInfo

        let indexPathForCell = IndexPath(row: indexPath, section: 0)
        self.tableView.reloadRows(at: [indexPathForCell], with: .fade)
    }
}
