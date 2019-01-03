//
//  UIImageView+Animation.swift
//  Livo
//
//  Created by Skuerth on 2019/1/1.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    func pulsate() {

        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.97
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0

        layer.add(pulse, forKey: nil)
    }
}
