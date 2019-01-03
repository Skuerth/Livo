//
//  UILabel+Extension.swift
//  Livo
//
//  Created by Skuerth on 2019/1/1.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation

extension UILabel {
    func addCharacterSpacing(kernValue: Double = 1.15) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
