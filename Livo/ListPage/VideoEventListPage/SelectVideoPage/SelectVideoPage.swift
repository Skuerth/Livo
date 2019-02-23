//
//  SelectVideoPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/26.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase

class SelectVideoPage: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var background: UIView!

    let spacing: CGFloat = 10
    let cellInset: CGFloat = 10
    var preScreenShot: UIImage?
    var addingNumberCount: Int = 0

    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height

//    var manager: ListPageManager?

    var liveStreamInfos: [LiveStreamInfo]?
    var selectedLiveStreams: [Int] = []
    var loadVideoType: LoadVideoType?
    let cellID = "InsertVideoPageCell"

    let manager: ListPageManager = {

        let manager = ListPageManager()
        return manager
    }()

    let uid: String? = {

        let uid = Auth.auth().currentUser?.uid
        return uid
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let loadVideoType = loadVideoType
        else { return }

        setUpNavigationTile(previousPageType: loadVideoType)

        fetchVideos(loadVideoType: loadVideoType)

        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        if preScreenShot != nil {

            imageView.image = preScreenShot
            view.addSubview(imageView)
        }

        self.background.addBlurEffect()

        view.sendSubviewToBack(imageView)

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.collectionView.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)

        setUpCollectionLayout()
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true

    }

// MARK: - IBAction Methods
    @IBAction func saveButton(_ sender: UIBarButtonItem) {

        if selectedLiveStreams.count > 0,

            let liveStreamInfos = liveStreamInfos {

            for selectedLiveStreamIndex in selectedLiveStreams {

                guard
                    let name = Auth.auth().currentUser?.displayName,
                    let uid = uid
                else {

                    UserInfoError.authorizationError.alert()
                    return
                }

                self.manager.sendSelectedLiveStreamToFirebase(uid: uid, name: name, index: selectedLiveStreamIndex)
            }

        } else if selectedLiveStreams.count == 0 {

            AlertHelper.customerAlert.rawValue.alert(message: "There is no selected video")
        }

        self.navigationController?.popViewController(animated: true)
    }

    func fetchVideos(loadVideoType: LoadVideoType) {

        switch loadVideoType {

        case .insertVideo:

            manager.fetchAllVideo()

        case .deleteVideo:

            guard let uid = uid else { return }

            manager.fetchMyUploadedVideos(uid: uid, completionHandler: { (myVideos) in

                if let myVideos = myVideos {

                    self.liveStreamInfos = myVideos

                    DispatchQueue.main.async {

                        self.collectionView.reloadData()

                        for (index, myVideo) in myVideos.enumerated() {

                            self.manager.loadImageByClosure(imageURL: myVideo.imageURL, index: index, loadVideoType: loadVideoType) { (liveStreamInfo, index) in

                                if
                                    let image = liveStreamInfo.image,
                                    var liveStreamInfos = self.liveStreamInfos {

                                    liveStreamInfos[index].image = image

                                    self.liveStreamInfos = liveStreamInfos

                                    let indexPath = IndexPath(item: index, section: 0)

                                    self.collectionView.reloadItems(at: [indexPath])

                                } else {

                                    print("fail to loadImageByClosure")
                                }
                            }
                        }
                    }
                }
            })
        }
    }

    func setUpCollectionLayout() {

        let layout = UICollectionViewFlowLayout()
        let collcollectionViewWidth = collectionView.frame.width
        let itemWidth = (collcollectionViewWidth - (spacing * 2) - cellInset) / 2

        layout.setUpFlowLayout(spacing: spacing, cellInset: cellInset, itemWidth: itemWidth, itemHeight: itemWidth * 1.6)

        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
   }

    func setUpNavigationTile(previousPageType: LoadVideoType) {

        switch previousPageType {

        case .insertVideo:

            self.navigationItem.title = NSLocalizedString("Youtube Video", comment: "")

        case .deleteVideo:

            self.navigationItem.title = "My Videos"
        }
    }
}

extension SelectVideoPage: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if liveStreamInfos?.count == 0 {

            AlertHelper.customerAlert.rawValue.alert(message: "There's no video in your youtube")
        }

        return liveStreamInfos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "InsertVideoPageCell", for: indexPath) as? InsertVideoPageCell else { return UICollectionViewCell() }

        guard let liveStreamInfos = self.liveStreamInfos else { return cell }

        cell.title.text = liveStreamInfos[indexPath.row].title

        if let image = liveStreamInfos[indexPath.item].image {

            cell.image.image = image
        }

        if liveStreamInfos[indexPath.row].isPressed == true {

            cell.blurEffectView.isHidden = false
            
        } else {

            cell.blurEffectView.isHidden = true
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard
            let cell = collectionView.cellForItem(at: indexPath) as? InsertVideoPageCell,
            var liveStreamInfos = liveStreamInfos
        else {
            return
        }

        if selectedLiveStreams.contains(indexPath.item) {

            selectedLiveStreams = selectedLiveStreams.filter() { $0 != indexPath.item }

            cell.imageContainerView.layer.shadowColor = UIColor.clear.cgColor
            cell.title.textColor = .black

            liveStreamInfos[indexPath.row].isPressed = false
            cell.blurEffectView.isHidden = true

            if addingNumberCount > 0 {

                addingNumberCount -= 1
            }

        } else {

            selectedLiveStreams.append(indexPath.item)
            cell.imageContainerView.pulsate()
            cell.title.textColor = UIColor(red: 27/255, green: 112/255, blue: 250/255, alpha: 1)
            attributesImageContainer(imageView: cell.image, containerView: cell.imageContainerView)

            liveStreamInfos[indexPath.row].isPressed = true
            cell.blurEffectView.isHidden = false

            addingNumberCount += 1
        }

        if addingNumberCount > 0 {

            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Add", comment: "") + "\(addingNumberCount)"
        } else {

//            self.navigationItem.title = NSLocalizedString("Profile", comment: "")

            self.navigationItem.rightBarButtonItem?.title = NSLocalizedString("Add", comment: "")
        }
        self.liveStreamInfos = liveStreamInfos
    }

    func attributesImageContainer(imageView: UIView, containerView: UIView) {

        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)

        containerView.layer.shadowOpacity = 0.7
        containerView.layer.cornerRadius = 7

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 7
    }
}

extension SelectVideoPage: ListPageManagerDelegate {

    func didFetchAllVideo(_ manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

        self.liveStreamInfos = liveStreamInfos
        self.collectionView.reloadData()

        guard let loadVideoType = loadVideoType else { return }

        for (index, liveStreamInfo) in liveStreamInfos.enumerated() {

            manager.loadImageByClosure(imageURL: liveStreamInfo.imageURL, index: index, loadVideoType: loadVideoType) { (_, _) in
            }
        }
    }

    func didFetchStreamInfo(manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

    }

    func didLoadimage(manager: ListPageManager, liveStreamInfo: LiveStreamInfo, indexPath: Int) {

        self.liveStreamInfos?[indexPath] = liveStreamInfo

        let indexPathForItem = IndexPath(item: indexPath, section: 0)
        self.collectionView.reloadItems(at: [indexPathForItem])
    }
}
