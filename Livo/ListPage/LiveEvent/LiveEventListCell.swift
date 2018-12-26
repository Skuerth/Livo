//
//  LiveEventListCell.swift
//  Livo
//
//  Created by Skuerth on 2018/12/18.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

class LiveEventListCell: UICollectionViewCell {

    @IBOutlet weak var broadcastImage: UIImageView!
    @IBOutlet weak var broadcastTitle: UILabel!
    @IBOutlet weak var broadcasterName: UILabel!
    @IBOutlet weak var imageContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        labelTextAtributesText(label: broadcastTitle)
        labelTextAtributesText(label: broadcasterName)

        attributesImageContainer(view: imageContainer)
    }

    func labelTextAtributesText(label: UILabel) {

        label.textColor = .black
    }

    func attributesImageContainer(view: UIView) {

        view.layer.shadowColor = UIColor.black.cgColor

        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.masksToBounds = false

    }

}
