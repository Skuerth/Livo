//
//  LiveStreaming.swift
//  Livo
//
//  Created by Skuerth on 2018/12/14.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import YTLiveStreaming
import LFLiveKit

protocol YouTubeLiveVideoOutput: class {

    func startPublishing(completed: @escaping (String?, String?) -> Void)
    func finishPublishing()
    func cancelPublishing()
}

class LiveStreamingViewController: UIViewController, YTLiveStreamingDelegate {

    var output: YouTubeLiveVideoOutput?
    var scheduledStartTime: NSData?
    var input: YTLiveStreaming?
    var liveBroadcastStreamModel: LiveBroadcastStreamModel?


    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var startLiveButton: UIButton!
    @IBOutlet weak var lfView: LFLivePreview!
    @IBOutlet weak var containerView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()


        self.input = YTLiveStreaming()
        self.containerView.backgroundColor = .clear
        
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(true)

        DispatchQueue.main.async {

            self.lfView.prepareForUsing()
        }
    }


    @IBAction func onClickPublish(_ sender: UIButton) {

        if startLiveButton.isSelected {

            startLiveButton.isSelected = false
            startLiveButton.setTitle("Start live broadcast", for: .normal)
            lfView.stopPublishing()
            output?.finishPublishing()

        } else {


            startLiveButton.isSelected = true
            startLiveButton.setTitle("Finish live broadcast", for: .normal)
            let date = Date.init(timeIntervalSinceNow: 0)
            self.createLiveBroadcast(date: date)
        }
    }

    func createLiveBroadcast(date: Date) {

        self.input?.createBroadcast("start test", description: "test", startTime: date, completion: { (liveBroadcastStreamModel) in

            if let liveBroadcastStreamModel = liveBroadcastStreamModel {

                self.liveBroadcastStreamModel = liveBroadcastStreamModel

                self.startBroadcast(liveBroadcastStreamModel: liveBroadcastStreamModel)
            } else {

            }
        })
    }


    
    func startBroadcast(liveBroadcastStreamModel: LiveBroadcastStreamModel) {

//        guard let liveBroadcastStreamModel = self.liveBroadcastStreamModel else { return }

        self.input?.startBroadcast(liveBroadcastStreamModel, delegate: self, completion: { streamName, streamUrl, scheduledStartTime in

            if let streamURL = streamUrl, let streamName = streamName {
                let streamUrl = "\(streamURL)/\(streamName)"

                self.lfView.startPublishing(withStreamURL: streamUrl)
            }
        })
    }


    func getUpcomingEvents() {
        self.input?.getUpcomingBroadcasts({ liveBroadcastStreamModels in

            guard let liveBroadcastStreamModels = liveBroadcastStreamModels else { return }

            for liveBroadcastStreamModel in liveBroadcastStreamModels {

                print("liveBroadcastStreamModel",liveBroadcastStreamModel)
            }
        })

    }
    @IBAction func closeButtonPressed(_ sender: UIButton) {


        self.getUpcomingEvents()

//        self.output?.cancelPublishing()
    }


}
