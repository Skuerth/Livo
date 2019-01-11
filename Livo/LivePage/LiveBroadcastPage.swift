//
//  LiveBroadcastPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/14.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import YTLiveStreaming
import LFLiveKit
import Firebase

class LiveBroadcastPage: UIViewController, LFLiveSessionDelegate {

    @IBOutlet weak var cameraButton: UIButton!

    var manager: LiveStreamManager?
    var videoID: String?
    let conversationViewController = ChatRoomPage()
    var activityIndicatorView: UIView = UIView()
    var blurEffectView = UIVisualEffectView()
    var activityIndicator = UIActivityIndicatorView()

    @IBOutlet weak var lfView: LFLivePreview!

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButton.setImage(UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cameraButton.tintColor = .white

        self.conversationViewController.channelID = self.videoID

        conversationViewController.willMove(toParent: self)
        self.addChild(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParent: self)

        createWaitingView()

        self.manager?.startBroadcast(lfView: self.lfView)
        self.manager?.delegate = self
        conversationViewController.messagesCollectionView.backgroundColor = .clear
        conversationViewController.view.backgroundColor = .clear

        view.sendSubviewToBack(conversationViewController.view)
        view.sendSubviewToBack(lfView)
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(true)

        DispatchQueue.main.async {

            self.lfView.prepareForUsing()
        }
    }

    override var canBecomeFirstResponder: Bool {

        return true
    }

    override var inputAccessoryView: UIView? {

        return conversationViewController.inputAccessoryView
    }

    @IBAction func pressedRotateButton(_ sender: UIButton) {

        lfView.changeCameraPosition()
    }

    @IBAction func stopPublish(_ sender: UIButton) {

        guard
            let liveStreamManager = self.manager,
            let id = liveStreamManager.liveBroadcastStreamModel?.id
        else {
            LiveStreamError.getLiveStreamInfoError.alert(message: "can't stop live stream")
            return
        }

        let liveBroadcastStreamRef = Database.database().reference(withPath: "liveBroadcastStream")

        lfView.stopPublishing()
        liveStreamManager.stopLiveBroadcast()

        let videoID = liveStreamManager.liveBroadcastStreamModel?.id

        liveBroadcastStreamRef.queryOrderedByKey().queryEqual(toValue: id).observeSingleEvent(of: .value) { snapshot in

            snapshot.ref.child(id).updateChildValues([

                "status": LiveStatus.completed.rawValue
                ])
        }

        let main = UIStoryboard(name: "Main", bundle: nil)

        if
            let mainTabbarPage = main.instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage,
            let appDelegate = UIApplication.shared.delegate
        {

            dismiss(animated: true) {

                appDelegate.window??.rootViewController = mainTabbarPage
            }
        }
    }

    deinit {

        lfView.stopPublishing()
        self.manager?.stopLiveBroadcast()
    }

    func createWaitingView() {

        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.frame = view.bounds
        vibrancyEffectView.frame = view.bounds

        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.addSubview(titleLabel)

        titleLabel.text = "connect to start"
        titleLabel.font = titleLabel.font.withSize(20)
        titleLabel.numberOfLines = 0
        titleLabel.sizeToFit()
        titleLabel.textColor = .lightGray

        activityIndicator = UIActivityIndicatorView(frame: .zero)
        activityIndicatorView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.style = .whiteLarge

        vibrancyEffectView.contentView.addSubview(titleLabel)
        vibrancyEffectView.contentView.addSubview(activityIndicator)
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        view.addSubview(blurEffectView)

        NSLayoutConstraint.activate([

            blurEffectView.widthAnchor.constraint(equalToConstant: 200),
            blurEffectView.heightAnchor.constraint(equalToConstant: 100),
            vibrancyEffectView.widthAnchor.constraint(equalToConstant: 200),
            vibrancyEffectView.heightAnchor.constraint(equalToConstant: 100),

            blurEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            blurEffectView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: blurEffectView.bottomAnchor, constant: -20),
            titleLabel.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor, constant: 0),
            activityIndicator.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor, constant: 0),
            activityIndicator.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5)
        ])

        vibrancyEffectView.layer.cornerRadius = 20
        vibrancyEffectView.layer.masksToBounds = true
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true

        activityIndicator.startAnimating()
    }
}

extension LiveBroadcastPage: LiveStreamManagerDelegate {

    func finishCreateLiveBroadcastStream(_ manager: LiveStreamManager) {

    }

    func didStartLiveBroadcast(_ manager: LiveStreamManager) {

        self.blurEffectView.isHidden = true
        self.activityIndicator.stopAnimating()
        AlertHelper.customerAlert.rawValue.alert(message: "Start Live Broadcast")
    }
}
