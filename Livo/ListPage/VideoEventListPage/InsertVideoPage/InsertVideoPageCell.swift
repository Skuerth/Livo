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

    override func awakeFromNib() {
        super.awakeFromNib()

        attributesImageContainer(imageView: image)
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
