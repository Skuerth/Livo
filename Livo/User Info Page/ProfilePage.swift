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

class ProfilePage: UIViewController, GIDSignInUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var googleAccount: UILabel!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var changeName: UIButton!

    var fetchManager: ListPageManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchManager = ListPageManager()

        self.navigationItem.title = NSLocalizedString("Profile", comment: "")

        if let currentUser = Auth.auth().currentUser {

            nameLabel.text = currentUser.displayName

            let uid = currentUser.uid

            let filePath = NSTemporaryDirectory() + "\(uid).jpg"

            if let image = UIImage(contentsOfFile: filePath) {

                self.loadUserPhoto(image: image, uid: uid)

            } else {

                let imageRef = Database.database().reference(withPath: "chatUser").child(uid)

                imageRef.observeSingleEvent(of: .value) { (snapshot) in

                    if let imageURL = snapshot.value as? String {

                        DispatchQueue.global().async {

                            guard let url = URL(string: imageURL) else { return }

                            if let data = try? Data(contentsOf: url) {

                                guard let image = UIImage(data: data) else { return }

                                DispatchQueue.main.async {

                                    self.loadUserPhoto(image: image, uid: uid)
                                }
                            }
                        }

                    } else {

                        if let image = UIImage(named: "user_placeholder") {

                            self.loadUserPhoto(image: image, uid: uid)

                        }
                    }
                }
            }
        }

        self.checkIsConnectGoogleAcoount()
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillLayoutSubviews() {

        self.userPhoto.contentMode = .scaleAspectFill
        makeCircleView(view: userPhoto)
        addShadow(view: photoView)
    }

    func showPopover(sender: UIButton) {

        guard
            let changeProfileDataPop = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeProfileDataPop") as? ChangeProfileDataPop
        else { return }

        changeProfileDataPop.modalPresentationStyle = .popover
        changeProfileDataPop.preferredContentSize = CGSize(width: 200, height: 100)
        changeProfileDataPop.delegate = self

        guard
            let controller = changeProfileDataPop.popoverPresentationController
        else { return }

        if sender == changeName {

            changeProfileDataPop.changeDayatype = ProfileDataChangeType.name

        } else if sender == changePassword {

            changeProfileDataPop.changeDayatype = ProfileDataChangeType.password
        }

        controller.delegate = self

        controller.sourceView = sender
        controller.sourceRect = sender.bounds

        controller.permittedArrowDirections = [.up, .down]

        self.present(changeProfileDataPop, animated: true, completion: nil)
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {

        return UIModalPresentationStyle.none
    }

// MARK: - IBAction Methods
    @IBAction func deleteMyVideo(_ sender: UIButton) {

        guard
            let manager = fetchManager,
            let uid = Auth.auth().currentUser?.uid
        else { return }

        manager.fetchMyUploadedVideos(uid: uid) { (myVideos) in

            if let myVideos = myVideos {

                guard let selectVideoPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectVideoPage") as? SelectVideoPage else { return }

                selectVideoPage.liveStreamInfos = myVideos
                selectVideoPage.previousPageType = ReasonType.deleteVideo

                self.navigationController?.present(selectVideoPage, animated: true, completion: nil)

            } else {

                print("myVideos = nil")
            }
        }
    }

    @IBAction func changeEmailSignInPassword(_ sender: UIButton) {

        showPopover(sender: sender)
    }

    @IBAction func changeUserName(_ sender: UIButton) {

        showPopover(sender: sender)
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

            UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
        }
    }

    @IBAction func disconnectButton(_ sender: UIButton) {

        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signOut()
        self.checkIsConnectGoogleAcoount()
    }

    @IBAction func editPhoto(_ sender: UIButton) {

        let imageController = UIImagePickerController()
        imageController.delegate = self
        imageController.sourceType = .savedPhotosAlbum
        imageController.allowsEditing = true

        present(imageController, animated: true, completion: nil)

    }

    func loadUserPhoto(image: UIImage, uid: String) {

        userPhoto.image = image

        makeCircleView(view: userPhoto)
        addShadow(view: photoView)
        userPhoto.contentMode = .scaleAspectFill

        self.saveImageToLocal(image: image, uid: uid)
    }

    func saveImageToLocal(image: UIImage, uid: String) {

        if let imageData = image.jpegData(compressionQuality: 0.9) {

            let filePath = NSTemporaryDirectory() + "\(uid).jpg"
            let fileURL = URL(fileURLWithPath: filePath)

            do {

                try imageData.write(to: fileURL)

            } catch let error {

                UserInfoError.saveImageError.alert(message: "\(error.localizedDescription)")
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        if
//            let cropRect = info[UIImagePickerController.InfoKey.cropRect] as? CGRect,
            let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
//            let croppingCgImg = originImg.cgImage?.cropping(to: cropRect)
        {

//            let image = UIImage(cgImage: originImg)

            guard
                let currentUser = Auth.auth().currentUser,
                let name = currentUser.displayName,
                let email = currentUser.email
            else {

                    UserInfoError.authorizationError.alert(message: "fail to get current user infomation")
                    return
            }

            let uid = currentUser.uid
            let share = UserShareInstance.sharedInstance()

            self.saveImageToLocal(image: editedImage, uid: uid)

            if share.currentUser != nil {

                share.currentUser?.photo = editedImage

            } else {

                share.currentUser = CurrentUser(name: name, emailLogInUID: uid, email: email, photo: editedImage)
            }

            DispatchQueue.main.async {

                self.userPhoto.image = editedImage
                self.userPhoto.contentMode = .scaleAspectFill

            }

            let imageRef = Storage.storage().reference().child("photos").child("\(uid).jpg")

            let scaleImage = editedImage.scale(newWidth: 640.0)
            guard let imageData = scaleImage.jpegData(compressionQuality: 0.9) else { return }

            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"

            imageRef.putData(imageData, metadata: metadata).observe(.success) { (snapshop) in

                imageRef.downloadURL(completion: { (url, error) in

                    if error != nil {

                        UserInfoError.authorizationError.alert(message: "\(error?.localizedDescription)")
                    }

                    if let downloadUrl = url {

                        let chatUserRef = Database.database().reference(withPath: "chatUser").child(uid)
                        chatUserRef.setValue(downloadUrl.absoluteString)

                    } else {

                    }
                })
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
        view.layer.cornerRadius = view.frame.width / 2.0
    }

    func makeCircleView(view: UIView) {

        view.layer.cornerRadius = view.frame.width / 2.0
        view.clipsToBounds = true
    }
}

extension ProfilePage: ChangeProfileDataPopDelegate {

    func didChangePassword(password: String) {

        if Auth.auth().currentUser != nil {

            Auth.auth().currentUser?.updatePassword(to: password, completion: { error in

                if let error = error {

                    UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")
                }

                AlertHelper.customerAlert.rawValue.alert(message: "Successful change password")
            })
        }
    }

    func didChangeUserName(name: String) {

        if let user = Auth.auth().currentUser {

            let changeRequest = user.createProfileChangeRequest()

            changeRequest.displayName = name

            changeRequest.commitChanges { (error) in

                if let error = error {

                    UserInfoError.authorizationError.alert(message: "\(error.localizedDescription)")

                } else {

                    DispatchQueue.main.async {

                        self.nameLabel.text = name
                    }

                    AlertHelper.customerAlert.rawValue.alert(message: "Successful change name")
                }
            }
        }
    }
}
