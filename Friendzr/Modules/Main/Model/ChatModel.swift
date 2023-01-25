//
//  ChatModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/10/2021.
//

import Foundation
import ObjectMapper

typealias ChatList = ChatListDataModel
typealias ConversationList = ConversationsDataModel

class ChatsListModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: ChatListDataModel? = nil
    var status:Int = 0
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        status  <- map["status"]
    }
}
class ChatListDataModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [UserChatObj]? = []
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        data    <- map["data"]
        pageNumber   <- map["pageNumber"]
        pageSize  <- map["pageSize"]
        totalRecords  <- map["totalRecords"]
        totalPages  <- map["totalPages"]
    }
}

class UserChatObj: NSObject,Mappable {
    
    var id:String = ""
    var chatName: String? = ""
    var image: String? = ""
    var isevent: Bool? = false
    var latestdate: String? = ""
    var latesttime: String? = ""
    var messages: String? = ""
    var isfrind:Bool? = false
    var isMute:Bool? = false
    var isArchive:Bool? = false
    var leavevent:Int? = 0
    var myevent:Bool? = false
    var leaveventchat:Bool = false
    var messagestype:Int? = 0
    var messagesattach:String? = ""
    var isChatGroup:Bool? = false
    var isChatGroupAdmin:Bool? = false
    var leaveGroup:Int? = 0
    var eventtype:String = ""
    var isSelected:Bool? = false
    var message_not_Read:Int = 0
    var isCommunityGroup:Bool = false
    var isSendEvent:Bool = false
    var isWhiteLabel:Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        chatName    <- map["name"]
        image  <- map["image"]
        isevent  <- map["isevent"]
        latestdate  <- map["latestdate"]
        latesttime  <- map["latesttime"]
        messages  <- map["messages"]
        isMute  <- map["muit"]
        isfrind  <- map["isfrind"]
        leavevent  <- map["leavevent"]
        leaveventchat  <- map["leaveventchat"]
        myevent  <- map["myevent"]
        messagestype  <- map["messagestype"]
        messagesattach  <- map["messagesattach"]
        isChatGroup  <- map["isChatGroup"]
        isChatGroupAdmin  <- map["isChatGroupAdmin"]
        leaveGroup <- map["leaveGroup"]
        eventtype <- map["eventtype"]
        isCommunityGroup <- map["isCommunityGroup"]
        message_not_Read <- map["message_not_Read"]
        isWhiteLabel <- map["isWhiteLabel"]
    }
}



class ConversationsResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: ConversationsDataModel? = nil
    var status:Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        status  <- map["status"]
    }
}

class ConversationsDataModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [UserConversationModel]? = []
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        data    <- map["data"]
        pageNumber   <- map["pageNumber"]
        pageSize  <- map["pageSize"]
        totalRecords  <- map["totalRecords"]
        totalPages  <- map["totalPages"]
    }
}
class UserConversationModel: NSObject,Mappable {
    
    var userId:String = ""
    var userName:String = ""
    var regestdata:String = ""
    var lat:String = ""
    var lang:String = ""
    var key:String = ""
    var image:String = ""
    var email:String = ""
    var displayedUserName:String = ""
    
    var joinDate:String? = ""
    var myEventO:Bool? = false
    var stutus: Int? = 0
    
    var chatGroupSubscriberType:Int = 0
    var clearChatDateTime:String = ""
    var isAdminGroup:Bool = false
    var isMuted:String = ""
    var leaveDateTime:String = ""
    var leaveGroup: Int? = 0
    var removedDateTime:String = ""
    
    var isSelected:Bool = false
    var isSendEvent:Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        userId    <- map["userId"]
        userName    <- map["userName"]
        regestdata    <- map["regestdata"]
        lat    <- map["lat"]
        lang    <- map["lang"]
        key    <- map["key"]
        image    <- map["image"]
        email    <- map["email"]
        displayedUserName    <- map["displayedUserName"]
        stutus <- map["stutus"]
        joinDate <- map["joinDate"]
        myEventO <- map["myEvent"]
        chatGroupSubscriberType <- map["chatGroupSubscriberType"]
        clearChatDateTime <- map["clearChatDateTime"]
        isAdminGroup <- map["isAdminGroup"]
        isMuted <- map["isMuted"]
        leaveDateTime <- map["leaveDateTime"]
        leaveGroup <- map["leaveGroup"]
        removedDateTime <- map["removedDateTime"]
    }
}

class SendMessageModel:Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: SendMessageObj? = nil
    var status:Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        status  <- map["status"]
    }
}

class SendMessageObj:Mappable {
    
    var id: String?
    var userId: String?
    var message: String?
    var messagetype: Int?
    var attach: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        userId   <- map["userId"]
        message   <- map["message"]
        messagetype   <- map["messagetype"]
        attach  <- map["attach"]
    }
}
