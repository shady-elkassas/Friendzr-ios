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
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
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
    
    var isMute:Bool?
    var isArchive:Bool?
    
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
    }
}



class ConversationsResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: ConversationsDataModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
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
    }
}

class SendMessageModel:Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: SendMessageObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
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
