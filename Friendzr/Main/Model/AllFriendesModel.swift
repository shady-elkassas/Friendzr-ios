//
//  AllFriendesModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import Foundation
import ObjectMapper

typealias FriendsList = [FriendObj]

class AllFriendesModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [FriendObj]?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}
