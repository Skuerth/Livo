//
//  InsertVideoPageCell.swift
//  Livo
//
//  Created by Skuerth on 2018/12/26.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

class InsertVideoPageCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var checkButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        attributesImageContainer(imageView: image)
        blurEffectView.layer.cornerRadius = blurEffectView.frame.width / 2.0
        blurEffectView.layer.masksToBounds = true
        checkButton.setImage(UIImage(named: "check-icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        checkButton.tintColor = UIColor(red: 9, green: 9, blue: 92, alpha: 0.9)
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

    func attributesImageContainer(imageView: UIView) {

        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 7
    }
}
