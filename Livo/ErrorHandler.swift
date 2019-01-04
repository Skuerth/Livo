//
//  ErrorHandler.swift
//  Livo
//
//  Created by Skuerth on 2019/1/4.
//  Copyright © 2019 Skuerth. All rights reserved.
//

import Foundation

enum UserInfoError: Error {
    
    case infoError
    case authorizationError
    case saveImageError
}

extension UserInfoError: CustomStringConvertible {

    var description: String {

        switch self {

        case .infoError: return "Lsot Required Information"
        case .authorizationError: return "Authorization Failure"
        case .saveImageError: return "Fail to Save Photo"
        }
    }
}

enum LiveStreamError: Error {

    case getLiveStreamInfoError
}

extension LiveStreamError: CustomStringConvertible {

    var description: String {

        switch self {

        case .getLiveStreamInfoError: return "Fail to Get Live Stream Infomation"
        }
    }
}

enum ViewControllerError: Error {

    case presentError
}

extension ViewControllerError: CustomStringConvertible {

    var description: String {

        switch self {

        case .presentError: return "Fail to present ViewController"
        }
    }
}

enum DatabaseError: Error {

    case connectionError
}

extension DatabaseError: CustomStringConvertible {

    var description: String {

        switch self {

        case .connectionError: return "Fail to Connect to Database"
        }
    }
}

