//
//  Error+Extension.swift
//  Livo
//
//  Created by Skuerth on 2018/12/20.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import UIKit

extension Error {

    func alert(with controller: UIViewController) {

        let alertController = UIAlertController(title: "Oops!", message: "\(self)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        controller.present(controller, animated: true, completion: nil)
    }
}
