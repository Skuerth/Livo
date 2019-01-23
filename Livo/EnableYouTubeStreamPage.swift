//
//  EnableYouTubeStreamPage.swift
//  Livo
//
//  Created by Skuerth on 2019/1/23.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit

class EnableYouTubeStreamPage: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var photo: UIImageView!

    var imageArray = [UIImage]()

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

        for index in 1...5 {

            guard let image = UIImage(named: "enable-live-stream-en-\(index)") else { return }

            imageArray.append(image)
        }

        setImages(imageArray)
    }

    @IBAction func pageControl(_ sender: UIPageControl) {

    }

    func setImages(_ images: [UIImage]) {

        for index in 0..<imageArray.count {

            let imageView = UIImageView()
            imageView.image = imageArray[index]
            let xPosition = UIScreen.main.bounds.width * CGFloat(index)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            imageView.contentMode = .scaleAspectFit

            scrollView.contentSize.width = scrollView.frame.width * CGFloat( index + 1)
            scrollView.addSubview(imageView)
            scrollView.delegate = self
        }
    }
}
