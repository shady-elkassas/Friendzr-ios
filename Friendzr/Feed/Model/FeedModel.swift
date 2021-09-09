//
//  FeedModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/09/2021.
//

import Foundation
import ObjectMapper

typealias UserFeedList = [UserFeedObj]

class FeedModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [UserFeedObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}
class UserFeedObj: Mappable {
    
    var userId: String?
    var lang: String?
    var lat: String?
    var displayedUserName: String?
    var email: String?
    var userName: String?

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        userId    <- map["userId"]
        lat    <- map["lat"]
        lang    <- map["lang"]
        displayedUserName    <- map["displayedUserName"]
        email    <- map["email"]
        userName    <- map["userName"]
    }
}
