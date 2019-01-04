//
//  Error+Extension.swift
//  Livo
//
//  Created by Skuerth on 2018/12/20.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import UIKit
import StatusAlert

extension Error {

    func alert(message: String = "") {

        let statusAlert = StatusAlert()
        statusAlert.appearance.blurStyle = .regular
        statusAlert.title = "\(self)"
        statusAlert.message = message
        statusAlert.appearance.titleFont = statusAlert.appearance.titleFont.withSize(16)
        statusAlert.canBePickedOrDismissed = true
        statusAlert.alertShowingDuration = 3
        statusAlert.showInKeyWindow()
    }
}
