//
//  NavigationPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/2.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit

class NavigationPage: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = UIColor.white
        self.navigationBar.tintColor = .white
        self.navigationBar.setValue(true, forKey: "hidesShadow")

        let titleShadow = NSShadow()
        titleShadow.shadowBlurRadius = 4
        titleShadow.shadowOffset = CGSize(width: 1, height: 1)
        titleShadow.shadowColor = UIColor.black

        self.navigationBar.titleTextAttributes = [

            NSAttributedString.Key.foregroundColor: UIColor(red: 246, green: 200, blue: 140),
            NSAttributedString.Key.font: UIFont(name: "Exo2-Light", size: 22)!,
            NSAttributedString.Key.shadow: titleShadow
        ]

        self.navigationBar.isTranslucent = false
        self.navigationItem.leftBarButtonItem?.tintColor = .white

        self.navigationBar.applyNavigationGradient(colors: [

            UIColor(red: 9, green: 9, blue: 92),
            UIColor(red: 15, green: 16, blue: 156)
        ])

        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.layer.shadowColor = UIColor.gray.cgColor
        self.navigationBar.layer.shadowOpacity = 0.8
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationBar.layer.shadowRadius = 2
    }
}
