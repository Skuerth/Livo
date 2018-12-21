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

class ClientWatchPage: UIViewController, UITextViewDelegate, YouTubePlayerDelegate {

    @IBOutlet weak var displayView: YouTubePlayerView!
    let conversationViewController = ChatRoomPage()

    override func viewDidLoad() {
        super.viewDidLoad()

        conversationViewController.willMove(toParent: self)
        self.addChild(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParent: self)

        displayView.delegate = self

        guard let url = URL(string: "https://www.youtube.com/watch?v=3YWIdXEF7tg") else { return }

        displayView.playerVars = [
            "playsinline": "1",
            "controls": "1",
            "showinfo": "0",
            "autoplay": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters

        displayView.loadVideoURL(url)

        conversationViewController.messageInputBar.inputTextView.delegate = self

    }



    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {

        if playerState.rawValue == "2" {

            print("pause")
        } else if playerState.rawValue == "1" {

            print("playing")
        } else {

            print("nothing")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        conversationViewController.messageInputBar.inputTextView.resignFirstResponder()
        return false
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        conversationViewController.messageInputBar.inputTextView.resignFirstResponder()
//        self.view.endEditing(true)
//    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

    override var canBecomeFirstResponder: Bool {
        return conversationViewController.messageInputBar.inputTextView.canBecomeFirstResponder
    }

    override var inputAccessoryView: UIView? {
        return conversationViewController.inputAccessoryView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = view.frame.height - displayView.frame.height
        conversationViewController.view.frame = CGRect(x: 0, y: displayView.frame.height, width: view.frame.width, height: height)
    }

    @IBAction func playButton(_ sender: UIButton) {

        if displayView.ready {
            if displayView.playerState != YouTubePlayerState.Playing {
                displayView.play()
            } else {
                displayView.pause()
            }
        }
    }
}
