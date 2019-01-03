//
//  MainTabbarPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/23.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

class MainTabbarPage: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBar.unselectedItemTintColor = .lightGray
        self.tabBar.tintColor = UIColor(red: 0/255, green: 16/255, blue: 172/255, alpha: 1)
        self.tabBar.tintColor = UIColor(red: 0, green: 16, blue: 172)
    }
}
