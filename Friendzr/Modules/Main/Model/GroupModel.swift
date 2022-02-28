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
    var chatGroupSubscribers:[ChatGroupSubscribersObj]? = []
    
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
    }
}


class ChatGroupSubscribersObj: Mappable {
    
    var removedDateTime: String?
    var clearChatDateTime: String?
    var isMuted: Bool?
    var status: Int?
    var type: Int?
    var userID: String?
    var userName:String?
    var leaveDateTime:String?
    var joinDateTime:String?
    var userImage:String? = ""
    var leaveGroup: Int? = 0
    var chatGroupSubscriberType:Int = 0
    var isAdminGroup:Bool = false
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        removedDateTime    <- map["removedDateTime"]
        clearChatDateTime   <- map["clearChatDateTime"]
        isMuted  <- map["isMuted"]
        status  <- map["status"]
        type  <- map["type"]
        userID  <- map["userID"]
        userName  <- map["userName"]
        leaveDateTime  <- map["leaveDateTime"]
        joinDateTime  <- map["joinDateTime"]
        userImage  <- map["userImage"]
        leaveGroup  <- map["leaveGroup"]
        chatGroupSubscriberType  <- map["chatGroupSubscriberType"]
        isAdminGroup  <- map["isAdminGroup"]
    }
}
