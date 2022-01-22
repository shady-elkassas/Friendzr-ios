//
//  NotificationsModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import Foundation
import ObjectMapper

typealias Notifications = NotificationsModel

class NotificationsResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: NotificationsModel?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class NotificationsModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [NotificationObj]? = []
    
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

class NotificationObj: NSObject,Mappable {
    
    var action: String? = ""
    var action_code: String? = ""
    var body: String? = ""
    var createdAt: String? = ""
    var id:String? = ""
    var messagetype:Int? = 0
    var muit:Bool? = false
    var title:String? = ""
    var imageUrl:String? = ""
    var isChatGroupAdmin:Bool = false
    required init?(map: Map) {
    }
    
    override init() {
        super.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        action   <- map["action"]
        action_code  <- map["action_code"]
        body  <- map["body"]
        createdAt  <- map["createdAt"]
        id  <- map["id"]
        messagetype  <- map["messagetype"]
        muit  <- map["muit"]
        title  <- map["title"]
        imageUrl  <- map["imageUrl"]
        isChatGroupAdmin  <- map["isChatGroupAdmin"]

    }
}
