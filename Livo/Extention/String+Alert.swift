//
//  String+Alert.swift
//  Livo
//
//  Created by Skuerth on 2019/1/4.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation
import StatusAlert

extension String {

    func alert(message: String = "") {

        let statusAlert = StatusAlert()
        statusAlert.appearance.blurStyle = .regular

        if self != "" {

            statusAlert.title = "\(self)"
            statusAlert.message = message

        } else {

            statusAlert.title = message
        }

        statusAlert.appearance.titleFont = statusAlert.appearance.titleFont.withSize(16)
        statusAlert.canBePickedOrDismissed = true
        statusAlert.alertShowingDuration = 3
        statusAlert.showInKeyWindow()
    }
}
