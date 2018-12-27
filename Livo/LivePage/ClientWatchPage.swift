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

        guard
            let videoID = self.videoID,
            let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)")
        else {
            return
        }

        displayView.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters

        displayView.loadVideoURL(url)

//        self.tabBarController?.tabBar.layer.zPosition = -1

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
        }
}
    // MARK: - Set Up InputBar
    func playerReady(_ videoPlayer: YouTubePlayerView) {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didPressDisplayView(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 2

        conversationViewController.view.addGestureRecognizer(tapGesture)

        videoPlayer.play()
    }

    @objc func didPressDisplayView(_ sender: UITapGestureRecognizer) {

        view.resignFirstResponder()
        conversationViewController.becomeFirstResponder()
        conversationViewController.messageInputBar.inputTextViewDidBeginEditing()
    }

    override var canBecomeFirstResponder: Bool {

        return true
    }

    override var inputAccessoryView: UIView? {
        return conversationViewController.inputAccessoryView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()


        let displayViewHeight = displayView.frame.height
        let topMargin = view.layoutMargins.top
        let height = view.frame.height - displayViewHeight - topMargin

         conversationViewController.view.frame = CGRect(x: 0, y: displayView.frame.height + topMargin, width: view.frame.width, height: height)
    }
}
