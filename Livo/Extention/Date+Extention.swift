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

extension String {

    func longDateStringConvertToshort() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"

        guard let date = dateFormatter.date(from: self) else { return  ""}

        dateFormatter.dateFormat = "MMM-dd-yyyy HH:mm:ss"

        let newDateString = dateFormatter.string(from: date)

        return newDateString
    }
}
