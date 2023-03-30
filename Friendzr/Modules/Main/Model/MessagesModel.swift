//
//  MessagesModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 04/10/2021.
//

import Foundation
import ObjectMapper

typealias MessagesChat = MessagesDataModel
typealias EventChatMessages = EventMessagesModel
typealias GroupChatMessages = GroupMessagesModel

class MessagesChatResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: MessagesDataModel? = nil
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

class MessagesDataModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [MessageObj]? = []
    
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


class MessageObj: NSObject,Mappable {
    
    var id: String? = ""
    var currentuserMessage: Bool? = false
    var userMessagessId: String? = ""
    var username: String? = ""
    var userimage: String? = ""
    var userId: String? = ""
    var messages: String? = ""
    var eventChatID: String? = ""
    var messagesdate: String? = ""
    var messagestime: String? = ""
    var messageAttachedVM: [MessageAttachedModel]? = []
    var messagetype:Int? = 0
    var eventData:EventObj? = nil
    var linkable:Bool = false
    var isWhitelabel:Bool = false
    var Latitude:String? = ""
    var Longitude:String? = ""

    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
    }

    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        currentuserMessage    <- map["currentuserMessage"]
        userMessagessId    <- map["userMessagessId"]
        username    <- map["username"]
        userimage    <- map["userimage"]
        userId    <- map["userId"]
        messages    <- map["messages"]
        eventChatID    <- map["eventChatID"]
        messagesdate    <- map["messagesdate"]
        messagestime    <- map["messagestime"]
        messageAttachedVM   <- map["messageAttachedVM"]
        messagetype   <- map["messagetype"]
        eventData   <- map["eventData"]
        linkable   <- map["linkable"]
        isWhitelabel   <- map["isWhitelabel"]
        Latitude   <- map["Latitude"]
        Longitude   <- map["Longitude"]
    }
}

class MessageAttachedModel: Mappable {
    
    var attached: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        attached  <- map["attached"]
    }
}

class EventChatMessagesResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: EventMessagesModel? = nil
    var statusCode:Int? = 0

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        statusCode  <- map["statusCode"]
    }
}

class EventMessagesModel: Mappable {
    
    var attendees: [UserConversationModel]?
    var pagedModel: MessagesDataModel?
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        attendees   <- map["attendees"]
        pagedModel  <- map["pagedModel"]
    }
}

class GroupChatMessagesResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: GroupMessagesModel? = nil
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

class GroupMessagesModel: Mappable {
    
    var subscribers: [UserConversationModel]?
    var pagedModel: MessagesDataModel?
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        subscribers   <- map["subscribers"]
        pagedModel  <- map["pagedModel"]
    }
}
