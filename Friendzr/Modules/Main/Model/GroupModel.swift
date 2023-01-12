//
//  GroupModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/01/2022.
//

import Foundation
import ObjectMapper

typealias GroupUsers = GroupModel


class GroupResponse : Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: GroupModel? = nil
    var status:Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        data  <- map["model"]
        status  <- map["status"]
    }
}

class GroupModel: Mappable {
    var id: String? = ""
    var name: String? = ""
    var image: String? = ""
    var isMuted: Bool? = false
    var isChatGroupAdmin: Bool? = false
    var leaveGroup: Int? = 0
    var listOfUserIDs: [String]? = []
    var registrationDateTime: String? = ""
    var chatGroupSubscribers:[UserConversationModel]? = []
    var isCommunityGroup:Bool = false
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        name   <- map["name"]
        image  <- map["image"]
        isMuted  <- map["isMuted"]
        listOfUserIDs  <- map["listOfUserIDs"]
        registrationDateTime  <- map["registrationDateTime"]
        chatGroupSubscribers  <- map["chatGroupSubscribers"]
        isChatGroupAdmin  <- map["isChatGroupAdmin"]
        leaveGroup  <- map["leaveGroup"]
        isCommunityGroup  <- map["isCommunityGroup"]
    }
}
