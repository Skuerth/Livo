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
import FirebaseStorage

class ProfilePage: UIViewController, GIDSignInUIDelegate, UIImagePickerControllerDelegate , UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var googleAccount: UILabel!
    @IBOutlet weak var photoView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = Auth.auth().currentUser?.displayName {

            nameLabel.text = name
        }

        if let userImage = UserShareInstance.sharedInstance().currentUser?.photo {

            userPhoto.image = userImage
        }

        self.checkIsConnectGoogleAcoount()

        makeCircleView(view: photoView)
        addShadow(view: photoView)
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true
        self.userPhoto.contentMode = .scaleAspectFit

        addShadow(view: userPhoto)
        makeCircleView(view: userPhoto)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showChangePasswordView" {

            let popover = segue.destination as? ChangePasswordPop
            popover?.preferredContentSize = CGSize(width: 200, height: 100)
            popover?.delegate = self

            let controller = popover?.popoverPresentationController

            if controller != nil {

                controller?.delegate = self

            }
        }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {

        return UIModalPresentationStyle.none
    }

    @IBAction func changeEmailSignInPassword(_ sender: UIButton) {

        performSegue(withIdentifier: "showChangePasswordView", sender: nil)

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

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            guard
                let currentUser = Auth.auth().currentUser,
                let name = currentUser.displayName,
                let email = currentUser.email
            else {
                return
            }

            let uid = currentUser.uid
            let share = UserShareInstance.sharedInstance()

            if share.currentUser != nil {

                share.currentUser?.photo = image

            } else {

                share.currentUser = User(name: name, email: email, emailLogInUID: uid, photo: image)
            }

            DispatchQueue.main.async {

                self.userPhoto.image = image
            }
            let imageRef = Storage.storage().reference().child("photos").child("\(uid).jpg")

            let scaleImage = image.scale(newWidth: 640.0)

            guard let imageData = scaleImage.jpegData(compressionQuality: 0.9) else { return }

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"

            let uploadTask = imageRef.putData(imageData, metadata: metadata)

            imageRef.downloadURL(completion: { (url, error) in

                if let url = url {

                    let request = currentUser.createProfileChangeRequest()

                    request.photoURL = url

                    request.commitChanges(completion: { (error) in

                        if let error = error {

                            print("fail to requesting chane displayNme with error(\(error.localizedDescription))")
                        }
                    })

                } else {

                }
            })

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

extension ProfilePage: ChangePasswordPopDelegate {

    func didChangePassword(password: String) {

        if Auth.auth().currentUser != nil {

            Auth.auth().currentUser?.updatePassword(to: password, completion: { error in

                if let error = error {

                    print("error", error)
                }

                print("password has changed")
            })
        }
    }
}
