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

class AttendeesObj: Mappable {
    
    var primaryId: Int?
    var stutus: Int?
    var userName: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        primaryId    <- map["primaryId"]
        userName   <- map["userName"]
        stutus <- map["stutus"]
    }
}
