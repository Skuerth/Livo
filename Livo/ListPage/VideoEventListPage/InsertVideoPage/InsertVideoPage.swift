//
//  InsertVideoPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/26.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

class InsertVideoPage: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var manager: ListPageManager?

    var liveStreamInfos: [LiveStreamInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager = ListPageManager()
        self.manager?.delegate = self

        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.manager?.fetchAllVideo()

        self.collectionView.register(UINib(nibName: "InsertVideoPageCell", bundle: nil), forCellWithReuseIdentifier: "InsertVideoPageCell")

        let layout = UICollectionViewFlowLayout()

        layout.setUpFlowLayout(spacing: 5, cellInset: 5, itemWidth: 125, itemHeight: 150)

        self.collectionView.collectionViewLayout = layout
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
