//
//  AttendeesModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 08/09/2021.
//

import Foundation
import ObjectMapper

typealias AttendeesList = [AttendeesObj]

class AttendeesModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [AttendeesObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AttendeesObj: NSObject,Mappable {
    
    var id: String? = ""
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
        id    <- map["id"]
        userName   <- map["userName"]
        stutus <- map["stutus"]
        image <- map["image"]
        joinDate <- map["joinDate"]
        myEventO <- map["myEvent"]
    }
}
