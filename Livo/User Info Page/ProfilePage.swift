//
//  ProfilePage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/27.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class ProfilePage: UIViewController, GIDSignInUIDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var googleAccount: UILabel!
    @IBOutlet weak var photoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = Auth.auth().currentUser?.displayName {

            nameLabel.text = name
        }

        if let user = UserShareInstance.sharedInstance().user {

            userPhoto.image = user.photo
            userPhoto.contentMode = .scaleAspectFit
            makeCircleView(view: userPhoto)
        }

        self.checkIsConnectGoogleAcoount()

        makeCircleView(view: photoView)
        addShadow(view: photoView)
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true
    }
    @IBAction func changeEmailSignInPassword(_ sender: UIButton) {

    }

    @IBAction func signOutAccount(_ sender: UIButton) {

        do {
            try Auth.auth().signOut()

            let main = UIStoryboard(name: "Main", bundle: nil)

            if
                let loginPage = main.instantiateViewController(withIdentifier: "LoginPage") as? LoginPage,
                let appDelegate = UIApplication.shared.delegate
            {

                dismiss(animated: true) {

                    appDelegate.window??.rootViewController = loginPage
                }
            }
        } catch let error {

            print("\(error.localizedDescription)")
        }
    }

    @IBAction func disconnectButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signOut()
        self.checkIsConnectGoogleAcoount()
    }

    @IBAction func editPhoto(_ sender: UIButton) {

        var imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = .savedPhotosAlbum
        imageController.allowsEditing = true

        present(imageController, animated: true, completion: nil)

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {


        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {

            DispatchQueue.main.async {

                let userShare = UserShareInstance.sharedInstance()

                if var user = userShare.user {

                    user.photo = image

                } else {

                    guard
                        let currentUser = Auth.auth().currentUser,
                        let name = currentUser.displayName,
                        let email = currentUser.email
                    else {
                        return
                    }

                    let uid = currentUser.uid

                    userShare.user = UserProfile(name: name, email: email, password: nil, emailLogInUID: uid, photo: image)
                }


                self.userPhoto.image = image
                self.userPhoto.contentMode = .scaleAspectFit
                self.makeCircleView(view: self.userPhoto)
            }
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

        dismiss(animated: true, completion: nil)
    }


    func checkIsConnectGoogleAcoount() {

        if GIDSignIn.sharedInstance()?.currentUser != nil {

            self.googleAccount.text = GIDSignIn.sharedInstance()?.currentUser.profile.email
        } else {

            self.googleAccount.text = "There's no connect to any account"
        }
    }

    func addShadow(view: UIView) {

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.7
        view.layer.masksToBounds = false
    }
    func makeCircleView(view: UIView) {

        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.frame.height/2
        view.clipsToBounds = true
    }
}
