//
//  VideoListCell.swift
//  Livo
//
//  Created by Skuerth on 2018/12/25.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

class VideoListCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        photoView.layer.masksToBounds = false
        photoView.layer.cornerRadius = 10
        photoView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
