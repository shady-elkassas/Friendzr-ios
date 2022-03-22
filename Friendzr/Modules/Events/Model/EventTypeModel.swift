//
//  EventTypeModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 22/03/2022.
//

import Foundation
import ObjectMapper

typealias EventTypeList = [EventTypeObj]

class EventTypeModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [EventTypeObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class EventTypeObj: Mappable {
    
    var entityId: String? = ""
    var name: String? = ""
    var color: String? = ""
    var privtekey: String? = ""

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        entityId    <- map["entityId"]
        name   <- map["name"]
        color   <- map["color"]
        privtekey   <- map["privtekey"]
    }
}
