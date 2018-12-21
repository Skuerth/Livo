//
//  LivoCredentials.swift
//  YTLiveStreaming
//
//  Created by Sergey Krotkih on 11/12/16.
//  Copyright © 2016 Sergey Krotkih. All rights reserved.
//

import UIKit

class LivoCredentials: NSObject {

    private static var _clientID: String?
    private static var _APIkey: String?
    private static var _oAuthClientID: String?

    private static let plistKeyClientID = "CLIENT_ID"
    private static let plistKeyAPIkey = "API_KEY"
    private static let plistKeyOAuthClientID = "OAuth_CLIENT_ID"

    class var oAuthClientID: String {
        if LivoCredentials._oAuthClientID == nil {
            if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
                if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
                    if let oAuthClientID = plist[plistKeyOAuthClientID] as? String, !oAuthClientID.isEmpty {
                        LivoCredentials._oAuthClientID = oAuthClientID
                    }

                }
            }
        }

        assert(LivoCredentials._oAuthClientID != nil, "Please put your OAuth2.0 Client ID to the Info.plist!")
        return LivoCredentials._oAuthClientID!
    }

    class var clientID: String {
      if LivoCredentials._clientID == nil {
         if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
               if let clientID = plist[plistKeyClientID] as? String, !clientID.isEmpty {
                  LivoCredentials._clientID = clientID
               }
            }
         }
      }
      assert(LivoCredentials._clientID != nil, "Please put your Client ID to the Info.plist!")
      return LivoCredentials._clientID!
   }

    class var APIkey: String {
      if LivoCredentials._APIkey == nil {
         if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as NSDictionary? {
               if let apiKey = plist[plistKeyAPIkey] as? String, !apiKey.isEmpty {
                  LivoCredentials._APIkey = apiKey
               }
            }
         }
      }
      assert(LivoCredentials._APIkey != nil, "Please put your APY key to the Info.plist!")
      return LivoCredentials._APIkey!
   }
}
