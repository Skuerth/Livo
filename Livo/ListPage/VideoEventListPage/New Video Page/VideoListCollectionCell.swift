//
//  VideoListCollectionCell.swift
//  Livo
//
//  Created by Skuerth on 2019/1/5.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit

class VideoListCollectionCell: UICollectionViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var radiusView: UIView!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var blurView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowOpacity = 0.6
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.cornerRadius = 8

        blurView.layer.cornerRadius = blurView.bounds.width / 2
        blurView.clipsToBounds = true

        radiusView.clipsToBounds = true
        radiusView.layer.cornerRadius = 8

        dislikeButton.setImage(UIImage(named: "dislike-icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        dislikeButton.tintColor = UIColor.gray
        dislikeButton.imageView?.contentMode = .scaleAspectFit
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}
