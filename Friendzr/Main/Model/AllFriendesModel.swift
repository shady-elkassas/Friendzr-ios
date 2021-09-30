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
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AllFriendesDataModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [FriendObj]? = []
    
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
