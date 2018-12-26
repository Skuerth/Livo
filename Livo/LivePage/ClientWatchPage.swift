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
            "controls": "1",
            "showinfo": "0",
            "autoplay": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters

        displayView.loadVideoURL(url)

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
    }

    @objc func didPressDisplayView(_ sender: UITapGestureRecognizer) {

//        let webView = displayView.subviews[0] as? UIWebView
//        webView?.scrollView.resignFirstResponder()
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
        let height = view.frame.height - displayView.frame.height
        conversationViewController.view.frame = CGRect(x: 0, y: displayView.frame.height, width: view.frame.width, height: height)
    }
}
