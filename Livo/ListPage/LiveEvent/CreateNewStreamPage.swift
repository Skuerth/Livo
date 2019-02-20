//
//  CreateNewStreamPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/20.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YTLiveStreaming
import GoogleSignIn
import Firebase

class CreateNewStreamPage: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var presentingView: UIView!
    @IBOutlet weak var submitButton: UIButton!

    var liveStreamManager: LiveStreamManager?
    var userProfile: [String: Any] = [:]
    var authCredential: AuthCredential?
    var activityIndicatorView: UIView?
    var activityIndicator = UIActivityIndicatorView()
    var createNewStreamPageSuperview: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.delegate = self
        descriptionTextField.delegate = self

        let activityIndicatorView = UIView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: presentingView.frame.width, height: presentingView.frame.height)
        presentingView.addSubview(activityIndicatorView)
        self.activityIndicatorView = activityIndicatorView

        self.activityIndicatorView?.isHidden = true

        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.addSubview(titleLabel)

        titleLabel.text = "Creating Live Broadcast"
        titleLabel.font = titleLabel.font.withSize(12)
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.textColor = .lightGray

        activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .gray

        NSLayoutConstraint.activate([

            titleLabel.bottomAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: -15),
            titleLabel.leadingAnchor.constraint(equalTo: activityIndicatorView.leadingAnchor, constant: 20),
            activityIndicator.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 25),
            activityIndicator.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
        ])

        activityIndicator.startAnimating()

        self.liveStreamManager = LiveStreamManager()
        self.liveStreamManager?.delegate = self

        self.presentingView.backgroundColor = .white
        self.presentingView.layer.cornerRadius = 10
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        GIDSignIn.sharedInstance()?.delegate = self

        self.keyboardWillShowObserve()
        self.keyboardWillHideObserve()
    }

    // MARK: - IBAction Method
    @IBAction func exitButton(_ sender: UIButton) {

        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    @IBAction func submitButton(_ sender: UIButton) {

        guard
            let title = self.titleTextField.text,
            title != "",
            let description = self.descriptionTextField.text,
            description != ""
        else {

            UserInfoError.infoError.alert(message: "please fill up title and description")
            return
        }

        self.activityIndicatorView?.isHidden = false
        self.submitButton.tintColor = .lightGray
        self.submitButton.isEnabled = false

        self.liveStreamManager?.createLiveBroadcast(title: title, description: description, viewController: self)

    }

    deinit {

        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - UITextField Method
extension CreateNewStreamPage: UITextFieldDelegate {

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

    @objc func keyboardWillShow(_ notification: Notification) {

        presentingView.transform = CGAffineTransform(translationX: 0, y: -80)
    }

    @objc func keyboardWillHide(_ notification: Notification) {

        presentingView.transform = CGAffineTransform.identity
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.view.endEditing(true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var maxLength = 0

        if textField == self.titleTextField {

            maxLength = 30

        } else if textField == self.descriptionTextField {

            maxLength = 50
        }

        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString

        if newString.length > maxLength &&  maxLength == 10 {

            AlertHelper.customerAlert.rawValue.alert(message: NSLocalizedString("Title Length to Long", comment: ""))

        } else if newString.length > maxLength &&  maxLength == 20 {

            AlertHelper.customerAlert.rawValue.alert(message: NSLocalizedString("Description Length to Long", comment: ""))
        }

        return newString.length <= maxLength
    }

}

// MARK: - LiveStreamManagerDelegate Method
extension CreateNewStreamPage: LiveStreamManagerDelegate {

    func didStartLiveBroadcast(_ manager: LiveStreamManager) {

    }

    func finishCreateLiveBroadcastStream(_ manager: LiveStreamManager) {

        if let liveBroadcastPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveBroadcastPage") as? LiveBroadcastPage {

            liveBroadcastPage.manager = manager

            guard
                let uid = Auth.auth().currentUser?.uid,
                let name = Auth.auth().currentUser?.displayName
            else {

                UserInfoError.authorizationError.alert(message: "google sign in problem")
                return
            }

            manager.saveLiveBroadcastStream(userUID: uid, userName: name)

            liveBroadcastPage.videoID = manager.liveBroadcastStreamModel?.id

            DispatchQueue.main.async {

                self.activityIndicator.stopAnimating()
                self.activityIndicatorView?.isHidden = true
                self.present(liveBroadcastPage, animated: true, completion: nil)
            }

        } else {

            AlertHelper.customerAlert.rawValue.alert(message: "Can't create a live stream")
        }
    }
}

extension CreateNewStreamPage: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {

        if user != nil {

            GoogleOAuth2.sharedInstance.accessToken = user.authentication.accessToken

        } else {

            UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
        }
    }
}
