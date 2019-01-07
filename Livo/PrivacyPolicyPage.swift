//
//  PrivacyPolicyPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/6.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyPage: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var exit: UIButton!
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        exit.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        exit.titleLabel?.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        exit.titleLabel?.layer.shadowOpacity = 1.0
        exit.titleLabel?.layer.shadowRadius = 2
        exit.titleLabel?.layer.masksToBounds = true

        self.setNeedsStatusBarAppearanceUpdate()
    }

    @IBAction func exitButton(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {

        guard
            let url = URL(string: "https://privacypolicies.com/privacy/view/691daafe8515c9d271379ddf4d246c8e")
        else {
            return
        }

        self.webView.frame = view.frame
        self.webView.load(URLRequest(url: url))
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {

        return UIStatusBarStyle.default
    }
}
