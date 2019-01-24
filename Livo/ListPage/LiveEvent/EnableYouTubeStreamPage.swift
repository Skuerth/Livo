//
//  EnableYouTubeStreamPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/23.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit
import SnapKit

class EnableYouTubeStreamPage: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!

    var imageArray = [UIImage]()
    var exitButton: UIButton?

    let scrollView: UIScrollView = {

        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        return scroll
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        view.sendSubviewToBack(scrollView)

        if let code = languageCode() {

            loadImages(launguageCode: code)
        }

        setImages(imageArray)
        setExitButton()
    }

    func languageCode() -> String? {
        return NSLocale.autoupdatingCurrent.languageCode
    }

    func loadImages(launguageCode: String) {

        for index in 1...5 {

            switch launguageCode {

            case "en":
                guard let image = UIImage(named: "enable-live-stream-en-\(index)") else { return }
                imageArray.append(image)

            case "zh":
                guard let image = UIImage(named: "enable-live-stream-zh-\(index)") else { return }
                imageArray.append(image)

            default:

                guard let image = UIImage(named: "enable-live-stream-en-\(index)") else { return }
                imageArray.append(image)
            }
        }
    }

    func setExitButton() {

        let button = UIButton(frame: .zero)
        button.setTitle("X", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.snp.makeConstraints({ (maker) in

            maker.top.equalTo(view).offset(10)
            maker.right.equalTo(view).offset(-10)
            maker.width.equalTo(25)
            maker.height.equalTo(25)
        })

        self.exitButton = button

        exitButton?.addTarget(self, action: #selector(didPressExit), for: .touchUpInside)
    }

    func setImages(_ images: [UIImage]) {

        for index in 0 ..< images.count {

            let imageView = UIImageView()
            imageView.image = images[index]

            let width = scrollView.frame.width
            let  height = scrollView.frame.height
            let statusHeight = UIApplication.shared.statusBarFrame.height

            guard
                let tabbarHeight = tabBarController?.tabBar.frame.size.height,
                let naviBarHeight = navigationController?.navigationBar.frame.height
            else { return }

            let imageHeight = height - tabbarHeight - naviBarHeight - statusHeight

            let xPosition = UIScreen.main.bounds.width * CGFloat(index)
            imageView.frame = CGRect(x: xPosition, y: imageHeight * 0.05, width: width, height: imageHeight * 0.9)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 15
            imageView.clipsToBounds = true

            scrollView.contentSize.width = scrollView.frame.width * CGFloat( index + 1)
            scrollView.addSubview(imageView)
            scrollView.delegate = self

            scrollView.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        }
    }

    @objc func didPressExit() {

        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension EnableYouTubeStreamPage: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let width = scrollView.frame.width
        let page = Int(round(scrollView.contentOffset.x / width))

        pageControl.currentPage = page

    }
}
