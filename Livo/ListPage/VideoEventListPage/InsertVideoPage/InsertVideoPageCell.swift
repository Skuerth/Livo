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

    override func awakeFromNib() {
        super.awakeFromNib()

        attributesImageContainer(view: image)
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

    func attributesImageContainer(view: UIView) {

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = false
        view.clipsToBounds = true
    }

}
