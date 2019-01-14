//
//  EULAPageCell.swift
//  Livo
//
//  Created by Skuerth on 2019/1/7.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import UIKit

class EULAPageCell: UITableViewCell {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var termLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        termLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        termLabel.numberOfLines = 0
        termLabel.sizeToFit()
    }

}
