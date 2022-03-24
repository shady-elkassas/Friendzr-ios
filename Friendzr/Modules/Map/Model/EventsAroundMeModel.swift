//
//  EventsAroundMeModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/09/2021.
//

import Foundation
import ObjectMapper

typealias EventsAroundList = EventsAroundMeDataModel
typealias EventsOnlyAroundList = EventsOnlyAroundMeModel

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

class EventsOnlyAroundMeResponse: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: EventsOnlyAroundMeModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}


class EventsOnlyAroundMeModel: Mappable {
    
    var pageSize: Int?
    var totalRecords: Int?
    var totalPages: Int?
    var pageNumber: Int?
    var data: [EventObj]? = []
    
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

class EventsAroundMeDataModel: Mappable {
    
    var eventlocationDataMV: [EventsAroundMeObj]? = nil
    var peoplocationDataMV: [PeopleAroundMeObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        eventlocationDataMV    <- map["eventlocationDataMV"]
        peoplocationDataMV   <- map["locationMV"]
    }
}

class EventsAroundMeObj: Mappable {
    
    var lang: Double? = 0.0
    var lat: Double? = 0.0
    var count: Int? = 0
    var color:String? = ""
    var eventData: [EventObj]? = nil
    var event_TypeId:String = ""
    var event_Type:String = ""
    var event_TypeColor:String = ""

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        lang    <- map["lang"]
        lat   <- map["lat"]
        count   <- map["count"]
        color   <- map["color"]
        eventData  <- map["eventData"]
        event_TypeId  <- map["event_TypeId"]
        event_Type  <- map["event_Type"]
        event_TypeColor  <- map["event_TypeColor"]
    }
}
