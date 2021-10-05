//
//  EventsAroundMeModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/09/2021.
//

import Foundation
import ObjectMapper

typealias EventsAroundList = EventsAroundMeDataModel

class EventsAroundMeModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: EventsAroundMeDataModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class EventsAroundMeDataModel: Mappable {
    
    var eventlocationDataMV: [EventsAroundMeObj]? = nil
    var peoplocationDataMV: [PeopleAroundMeObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        eventlocationDataMV    <- map["eventlocationDataMV"]
        peoplocationDataMV   <- map["peoplocationDataMV"]
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

class PeopleAroundMeObj: Mappable {
    
    var lang: Double? = 0.0
    var lat: Double? = 0.0
    var peoplecount: Int? = 0
    var peoplecolor:String? = ""
    var peopleMV: [PeopleObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        lang    <- map["lang"]
        lat   <- map["lat"]
        peoplecount   <- map["peoplecount"]
        peoplecolor   <- map["peoplecolor"]
        peopleMV  <- map["peopleMV"]
    }
}

class PeopleObj: Mappable {
    
    var type:String? = ""
    var count: Int? = 0
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        type   <- map["type"]
        count  <- map["count"]
    }
}
