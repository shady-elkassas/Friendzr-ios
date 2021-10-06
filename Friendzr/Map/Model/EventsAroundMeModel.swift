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
    var color:String? = ""
    var malePercentage: Double? = 0.0
    var femalepercentage: Double? = 0.0
    var otherpercentage: Double? = 0.0
    var totalUsers: Int? = 0

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        lang    <- map["lang"]
        lat   <- map["lat"]
        color   <- map["color"]
        malePercentage  <- map["malePercentage"]
        femalepercentage   <- map["femalepercentage"]
        otherpercentage   <- map["otherpercentage"]
        totalUsers   <- map["totalUsers"]

    }
}
