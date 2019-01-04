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

        let localizationFont = font(from: localizedFontName(), size: localizedFontSize())
        print("localizationFont", localizationFont)

        self.navigationBar.titleTextAttributes = [

            NSAttributedString.Key.foregroundColor: UIColor(red: 246, green: 200, blue: 140),
            NSAttributedString.Key.font: localizationFont,
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

    func languageCode() -> String? {
        return NSLocale.autoupdatingCurrent.languageCode
    }

    func localizedFontName() -> String {
        let defaultFont = "Arial"
        guard let code = languageCode() else {
            return defaultFont
        }
        switch code {
        case "en":
            return "Exo2-Light"
        case "zh":
            return "GenWanMinTW-Regular-TTF"
        default:
            return defaultFont
        }
    }

    func localizedFontSize() -> CGFloat {

        let defaultFontSize: CGFloat = 16.0
        guard let code = languageCode() else {
            return defaultFontSize
        }
        switch code {
        case "en":
            return 22.0
        case "zh":
            return 18.0
        default:
            return defaultFontSize
        }
    }

    func font(from name: String, size: CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor(name: name, size: size)

        return UIFont(descriptor: descriptor, size: size)
    }
}
