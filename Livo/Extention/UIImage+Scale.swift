//
//  UIImage+Scale.swift
//  Livo
//
//  Created by Skuerth on 2018/12/28.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation

extension UIImage {

    func scale(newWidth: CGFloat) -> UIImage {

        if self.size.width == newWidth {

            return self
        }

        let scaleFactor = newWidth / self.size.width
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? self
    }
}
