//
//  AllFriendesModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import Foundation
import ObjectMapper

typealias FriendsList = AllFriendesDataModel

class AllFriendesModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: AllFriendesDataModel?
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

class AllFriendesDataModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [friendChatObj]? = []
    
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

class friendChatObj: NSObject,Mappable {

    var userName:String? = ""
    var userId:String? = ""
    var lat:String? = ""
    var lang:String? = ""
    var key:Int? = 0
    var image:String? = ""
    var email:String? = ""
    var displayedUserName:String? = ""
    var age:String? = ""
    var regestdata:String? = ""
    
    required init?(map: Map) {
    }
    
    override init() {
        super.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        age    <- map["age"]
        displayedUserName    <- map["displayedUserName"]
        email    <- map["email"]
        image    <- map["image"]
        key    <- map["key"]
        lang    <- map["lang"]
        lat    <- map["lat"]
        regestdata    <- map["regestdata"]
        userId    <- map["userId"]
        userName    <- map["userName"]
    }
}
