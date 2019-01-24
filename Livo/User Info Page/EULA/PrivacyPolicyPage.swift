//
//  PrivacyPolicyPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/6.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class PrivacyPolicyPage: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var displayView: UITextView!
    var exitButton: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton()

//        exitButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
//        exitButton.titleLabel?.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
//        exitButton.titleLabel?.layer.shadowOpacity = 1.0
//        exitButton.titleLabel?.layer.shadowRadius = 2
//        exitButton.titleLabel?.layer.masksToBounds = true

//        self.setNeedsStatusBarAppearanceUpdate()

        displayView.text = NSLocalizedString("Privacy Policy", comment: "")
        displayView.isEditable = false
    }

    func setupButton() {

        let button = UIButton(frame: .zero)
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(30)
        button.setTitleColor(.black, for: .normal)
        view.addSubview(button)

        exitButton = button

        exitButton?.addTarget(self, action: #selector(exitButton(_:)), for: .touchUpInside)

        exitButton?.translatesAutoresizingMaskIntoConstraints = false

        exitButton?.snp.makeConstraints({ (maker) in

            maker.top.equalTo(view).offset(10)
            maker.right.equalTo(view).offset(-10)
        })
    }

    @objc func exitButton(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }

//    override var preferredStatusBarStyle: UIStatusBarStyle {
//
//        return UIStatusBarStyle.default
//    }
}
