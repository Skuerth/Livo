//
//  ChangePasswordPop.swift
//  Livo
//
//  Created by Skuerth on 2018/12/27.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

protocol ChangeProfileDataPopDelegate: class {

    func didChangePassword(password: String)
    func didChangeUserName(name: String)
}

class ChangeProfileDataPop: UIViewController {

    var changeDayatype: ProfileDataChangeType?

    @IBOutlet weak var inputTextField: UITextField!

    weak var delegate: ChangeProfileDataPopDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let changeDayatype = changeDayatype else { return }

        switch changeDayatype {

        case .name:

            inputTextField.placeholder = "new name"

        case .password:

            inputTextField.isSecureTextEntry = true
        }
    }

    @IBAction func submit(_ sender: UIButton) {

        didSubmit()
    }

    func didSubmit() {

        guard
            let changeDayatype = changeDayatype,
            let inputText = inputTextField.text,
            inputText != ""
        else { return }

        switch changeDayatype {

        case .name:

            dismiss(animated: true, completion: {

                self.delegate?.didChangeUserName(name: inputText)
            })

        case .password :


            dismiss(animated: true, completion: {

                self.delegate?.didChangePassword(password: inputText)
            })
        }
    }
}
