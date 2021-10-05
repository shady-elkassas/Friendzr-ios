//
//  MessagesModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 04/10/2021.
//

import Foundation
import ObjectMapper

typealias MessagesChat = MessagesDataModel

class MessagesChatResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: MessagesDataModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
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
    
    var id: String?
    var currentuserMessage: Bool?
    var userMessagessId: String?
    var username: String?
    var userimage: String?
    var userId: String?
    var messages: String?
    var eventChatID: String?
    var messagesdate: String?
    var messagestime: String?
    var messageAttachedVM: String?

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
    }
}
