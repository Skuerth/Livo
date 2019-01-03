//
//  InsertVideoPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/26.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import Firebase

class InsertVideoPage: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var background: UIView!

    let spacing: CGFloat = 10
    let cellInset: CGFloat = 10
    var preScreenShot: UIImage?

    var manager: ListPageManager?

    var liveStreamInfos: [LiveStreamInfo]?
    var selectedLiveStreams: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        if preScreenShot != nil {

            imageView.image = preScreenShot
            view.addSubview(imageView)
        }

        self.background.addBlurEffect()

        view.sendSubviewToBack(imageView)

        self.manager = ListPageManager()
        self.manager?.delegate = self

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.manager?.fetchAllVideo()

        self.collectionView.register(UINib(nibName: "InsertVideoPageCell", bundle: nil), forCellWithReuseIdentifier: "InsertVideoPageCell")

        setUpCollectionLayout()
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true

    }

    @IBAction func saveButton(_ sender: UIBarButtonItem) {

        if selectedLiveStreams.count > 0,
            let liveStreamInfos = liveStreamInfos {

            for selectedLiveStreamIndex in selectedLiveStreams {

                guard
                    let name = Auth.auth().currentUser?.displayName,
                    let uid = Auth.auth().currentUser?.uid
                else {
                        return
                }

                self.manager?.sendSelectedLiveStreamToFirebase(uid: uid, name: name, index: selectedLiveStreamIndex)
            }

        } else {

        }

        self.navigationController?.popViewController(animated: true)
    }

    func setUpCollectionLayout() {

        let layout = UICollectionViewFlowLayout()

        let collcollectionViewWidth = collectionView.frame.width
        let itemWidth = (collcollectionViewWidth - (spacing * 2) - cellInset) / 2

        layout.setUpFlowLayout(spacing: spacing, cellInset: cellInset, itemWidth: itemWidth, itemHeight: itemWidth * 0.967)

        collectionView.collectionViewLayout = layout
        collectionView.showsVerticalScrollIndicator = false
   }
}

extension InsertVideoPage: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return liveStreamInfos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "InsertVideoPageCell", for: indexPath) as? InsertVideoPageCell else { return UICollectionViewCell() }

        guard let liveStreamInfos = self.liveStreamInfos else { return cell }

        cell.title.text = liveStreamInfos[indexPath.row].title

        if let image = liveStreamInfos[indexPath.item].image {

            cell.image.image = image
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let cell = collectionView.cellForItem(at: indexPath) as? InsertVideoPageCell else { return }

        if selectedLiveStreams.contains(indexPath.item) {

            selectedLiveStreams = selectedLiveStreams.filter() { $0 != indexPath.item }

            cell.imageContainerView.layer.shadowColor = UIColor.clear.cgColor
            cell.title.textColor = .black

        } else {

            selectedLiveStreams.append(indexPath.item)
            cell.imageContainerView.pulsate()
            cell.title.textColor = UIColor(red: 27/255, green: 112/255, blue: 250/255, alpha: 1)
            attributesImageContainer(imageView: cell.image, containerView: cell.imageContainerView)
        }
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

extension InsertVideoPage: ListPageManagerDelegate {

    func didFetchAllVideo(_ manager: ListPageManager, liveStreamInfos: [LiveStreamInfo]) {

        self.liveStreamInfos = liveStreamInfos
        self.collectionView.reloadData()

        var index = 0

        for liveStreamInfo in liveStreamInfos {

            self.manager?.loadImage(imageURL: liveStreamInfo.imageURL, indexPath: index)

            index += 1
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
