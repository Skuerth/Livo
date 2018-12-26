//
//  VideoListPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/25.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

class VideoListPage: UITableViewController {

    var manager: ListPageManager?
    var liveStreamInfos: [LiveStreamInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.manager = ListPageManager()
        self.manager?.fetchStreamInfo(status: LiveStatus.completed)
        self.manager?.delegate = self

        tableView.estimatedRowHeight = 100

        tableView.rowHeight = UITableView.automaticDimension

        self.tableView.register(UINib(nibName: "VideoListCell", bundle: nil), forCellReuseIdentifier: "VideoListCell")

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        print("iveStreamInfos?.count", liveStreamInfos?.count)

        return liveStreamInfos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListCell", for: indexPath) as? VideoListCell else {

            return UITableViewCell()
        }

        guard let liveStreamInfos = liveStreamInfos else { return  cell }

        cell.titleLabel.text = liveStreamInfos[indexPath.row].title
        cell.nameLabel.text = liveStreamInfos[indexPath.row].userName
        cell.dateLabel.text = liveStreamInfos[indexPath.row].startTime

        if let image = liveStreamInfos[indexPath.item].image {

            cell.photoView.image = image
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let clientWatchPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ClientWatchPage") as? ClientWatchPage,
            let liveStreamInfos = self.liveStreamInfos {

            clientWatchPage.videoID = liveStreamInfos[indexPath.row].videoID

            present(clientWatchPage, animated: true, completion: nil)
        }
    }
}

extension VideoListPage: ListPageManagerDelegate {

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
