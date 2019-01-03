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

    var liveStreamManager: LiveStreamManager?
    var videoID: String?
    let conversationViewController = ChatRoomPage()

    @IBOutlet weak var lfView: LFLivePreview!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.conversationViewController.channelID = self.videoID

        conversationViewController.willMove(toParent: self)
        self.addChild(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.didMove(toParent: self)

        self.liveStreamManager?.startBroadcast(lfView: self.lfView)

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

    @IBAction func stopPublish(_ sender: UIButton) {

        guard
            let liveStreamManager = self.liveStreamManager,
            let id = liveStreamManager.liveBroadcastStreamModel?.id
        else {
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
}
