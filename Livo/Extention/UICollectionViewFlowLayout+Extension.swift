//
//  UICollectionViewFlowLayout+Extension.swift
//  Livo
//
//  Created by Skuerth on 2018/12/26.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation

extension UICollectionViewFlowLayout {

    func setUpFlowLayout(spacing: CGFloat, cellInset: CGFloat, itemWidth: CGFloat, itemHeight: CGFloat) {

        self.sectionInset = UIEdgeInsets(
                                top: CGFloat(spacing),
                                left: CGFloat(spacing),
                                bottom: CGFloat(spacing),
                                right: CGFloat(spacing))

        self.minimumLineSpacing = CGFloat(cellInset)
        self.minimumInteritemSpacing = CGFloat(cellInset)

        self.estimatedItemSize = CGSize(width: itemWidth ,
                                          height: itemHeight)
    }
}
