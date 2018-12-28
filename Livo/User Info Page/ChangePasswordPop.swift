//
//  ChangePasswordPop.swift
//  Livo
//
//  Created by Skuerth on 2018/12/27.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit

protocol ChangePasswordPopDelegate: class {

    func didChangePassword(password: String)
}

class ChangePasswordPop: UIViewController {


    @IBOutlet weak var passwordTextField: UITextField!

    weak var delegate: ChangePasswordPopDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func submit(_ sender: UIButton) {

        if let password = passwordTextField.text {


            dismiss(animated: true, completion: {

                self.delegate?.didChangePassword(password: password)
            })
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
