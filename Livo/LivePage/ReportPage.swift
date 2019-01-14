//
//  ReportPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/14.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit
import Firebase

class ReportPage: UIViewController {

    @IBOutlet weak var pickerBox: UIView!
    @IBOutlet weak var pickerView: UIPickerView!

    var reportOptions: [String] = [
        "Sexual Content", "Violent or repulsive content", "Hateful or abusive content", "Child abuse", "Spam or misleading", "Other objectionable content"
    ]
    var didSelectedOption: String?
    var videoID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        didSelectedOption = reportOptions[0]
    }

    @IBAction func submitButton(_ sender: UIButton) {

        guard
            let didSelectedOption = didSelectedOption,
            let videoID = videoID,
            let currentUser = UserShareInstance.sharedInstance().currentUser
        else {
            return
        }

        let uid = currentUser.emailLogInUID

        let reportRef = Database.database().reference(withPath: "report").child(videoID)

        reportRef.setValue([
            uid: didSelectedOption
        ])

        dismissPickerView()
    }

    @IBAction func didPreddExitButton(_ sender: UIButton) {

        dismissPickerView()
    }

    func dismissPickerView() {

        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

}

extension ReportPage: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return reportOptions.count ?? 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        let tieleForRow = reportOptions[row]

        return tieleForRow
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        didSelectedOption = reportOptions[row]
    }
}
