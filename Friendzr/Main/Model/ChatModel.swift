//
//  ChatModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 03/10/2021.
//

import Foundation
import ObjectMapper

typealias ChatList = ChatListDataModel

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


class SendMessageModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
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
    }
}
