//
//  UIView+Extension.swift
//  Livo
//
//  Created by Skuerth on 2018/12/28.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation

extension UIView {

    func attributesImageContainer() {

        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.7
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.masksToBounds = false
    }

    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.opacity = 1
        blurEffectView.frame = self.bounds

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}
