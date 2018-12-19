//
//  ClientWatchPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/18.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import YouTubePlayer

class ClientWatchPage: UIViewController {

    @IBOutlet weak var displayView: YouTubePlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

//        let frame = self.view.frame

//        self.displayView = YouTubePlayerView(frame: frame)

        guard let url = URL(string: "https://www.youtube.com/watch?v=3YWIdXEF7tg") else { return }

        displayView.playerVars = [
            "playsinline": "1",
            "controls": "0",
            "showinfo": "0"
            ] as YouTubePlayerView.YouTubePlayerParameters

        displayView.loadVideoURL(url)

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
