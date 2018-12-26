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

    var manager: VideoManager?
    var liveStreamInfos: [LiveStreamInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager?.delegate = self

        self.manager?.fetchAllVideo()
    }
}

extension InsertVideoPage: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return liveStreamInfos?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return UICollectionViewCell()
    }
}

extension InsertVideoPage: VideoManagerDelegate {


    func didFetchAllVideo(_ manager: VideoManager, liveStreamInfos: [LiveStreamInfo]) {

        self.liveStreamInfos = liveStreamInfos        
    }
}
