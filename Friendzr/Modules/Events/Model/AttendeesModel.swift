//
//  AttendeesModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 08/09/2021.
//

import Foundation
import ObjectMapper

typealias AttendeesList = AttendeesModel


class AttendeesResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: AttendeesModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AttendeesModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [AttendeesObj]? = nil
    
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

class AttendeesObj: NSObject,Mappable {
    
    var userId: String? = ""
    var stutus: Int? = 0
    var userName: String? = ""
    var image:String? = ""
    var joinDate:String? = ""
    var myEventO:Bool? = false
    
    required init?(map: Map) {
    }
    
    override init() {
        super.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        userId    <- map["userId"]
        userName   <- map["userName"]
        stutus <- map["stutus"]
        image <- map["image"]
        joinDate <- map["joinDate"]
        myEventO <- map["myEvent"]
    }
}
