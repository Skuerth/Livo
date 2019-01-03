//
//  TextfieldManager.swift
//  Livo
//
//  Created by Skuerth on 2019/1/3.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation

class TextfieldManager: NSObject, UITextFieldDelegate {

    func keyboardWillShowObserve() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    func keyboardWillHideObserve() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification, container: UIView) {

        container.transform = CGAffineTransform(translationX: 0, y: -120)
    }

    @objc func keyboardWillHide(_ notification: Notification, container: UIView) {

        container.transform = CGAffineTransform.identity
    }

}
