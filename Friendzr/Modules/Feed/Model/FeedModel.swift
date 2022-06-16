//
//  FeedModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/09/2021.
//

import Foundation
import ObjectMapper

typealias UsersList = FeedDataModel

class FeedModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: FeedDataModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class FeedDataModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [UserFeedObj]? = []
    
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

class UserFeedObj: NSObject,Mappable {
    
    var userId: String? = ""
    var lang: String? = ""
    var lat: String? = ""
    var displayedUserName: String? = ""
    var email: String? = ""
    var userName: String? = ""
    var image: String? = ""
    var key: Int? = 0
    var regestdata:String? = ""
    var interestMatchPercent:Int? = 0
    
    required init?(map: Map) {
    }
    
    override init() {
        super.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        userId    <- map["userId"]
        lat    <- map["lat"]
        lang    <- map["lang"]
        displayedUserName    <- map["displayedUserName"]
        email    <- map["email"]
        userName    <- map["userName"]
        image    <- map["image"]
        key    <- map["key"]
        regestdata    <- map["regestdata"]
        interestMatchPercent    <- map["interestMatchPercent"]
    }
}
