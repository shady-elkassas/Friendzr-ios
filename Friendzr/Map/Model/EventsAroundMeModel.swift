//
//  EventsAroundMeModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/09/2021.
//

import Foundation
import ObjectMapper

typealias EventsAroundList = [EventsAroundMeObj]

class EventsAroundMeModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [EventsAroundMeObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class EventsAroundMeObj: Mappable {
    
    var lang: Double? = 0.0
    var lat: Double? = 0.0
    var count: Int? = 0
    var color:String? = ""
    var eventData: [EventObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        lang    <- map["lang"]
        lat   <- map["lat"]
        count   <- map["count"]
        color   <- map["color"]
        eventData  <- map["eventData"]
    }
}
