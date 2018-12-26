//
//  Date+Extention.swift
//  Livo
//
//  Created by Skuerth on 2018/12/23.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation

extension Date {

    func dateConvertToString() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        let dateString = dateFormatter.string(from: self)

        return dateString
    }
}
