//
//  UIColor+RGBValue.swift
//  Livo
//
//  Created by Skuerth on 2019/1/2.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation

extension UIColor {

    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
