//
//  ClientWatchPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/18.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YouTubePlayer
import Firebase
import MessageKit

class ClientWatchPage: UIViewController, UITextViewDelegate, YouTubePlayerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var displayView: YouTubePlayerView!

    let conversationViewController = ChatRoomPage()
    var videoID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.conversationViewController.channelID = self.videoID
        self.conversationViewController.view.backgroundColor = .white

        conversationViewController.willMove(toParent: self)
        self.addChild(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParent: self)

        displayView.delegate = self
        displayView.delegate?.playerQualityChanged(displayView, playbackQuality: .Large)

        guard
            let videoID = self.videoID,
            let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)")
        else {

            LiveStreamError.getLiveStreamInfoError.alert(message: "can't get video info")
            return
        }

        displayView.playerVars = [
            "playsinline": "1"
//            "controls": "0",
//            "showinfo": "0",
//            "autoplay": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters

        displayView.loadVideoURL(url)
        view.sendSubviewToBack(displayView)
        conversationViewController.messagesCollectionView.backgroundColor = .clear
        conversationViewController.view.backgroundColor = .clear
    }

    deinit {

            self.navigationController?.setNavigationBarHidden(false, animated: true)
            UIApplication.shared.isStatusBarHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {

        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func playButton(_ sender: UIButton) {
    }

    @IBAction func pauseButton(_ sender: Any) {
    }

    @IBAction func exit(_ sender: UIButton) {

        if
            let mainTabbarPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabbarPage") as? MainTabbarPage,
            let appDelegate = UIApplication.shared.delegate
        {

            dismiss(animated: true) {

                appDelegate.window??.rootViewController = mainTabbarPage
            }
        } else {

            ViewControllerError.presentError.alert(message: "can't present to mainTabbarPage")
        }
}
    // MARK: - Set Up InputBar
    func playerReady(_ videoPlayer: YouTubePlayerView) {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didPressDisplayView(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 2

        conversationViewController.view.addGestureRecognizer(tapGesture)

        videoPlayer.play()

//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        UIApplication.shared.isStatusBarHidden = true

    }

    @objc func didPressDisplayView(_ sender: UITapGestureRecognizer) {

//        view.resignFirstResponder()
        conversationViewController.becomeFirstResponder()
        conversationViewController.messageInputBar.inputTextViewDidBeginEditing()

        if let isHidden = self.navigationController?.navigationBar.isHidden {

            self.navigationController?.setNavigationBarHidden(!isHidden, animated: true)

            UIApplication.shared.isStatusBarHidden = !isHidden
        }
    }

    override var canBecomeFirstResponder: Bool {

        return true
    }

    override var inputAccessoryView: UIView? {
        return conversationViewController.inputAccessoryView
    }

    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        if playerState == .Paused {
            videoPlayer.play()
        }
    }
}
