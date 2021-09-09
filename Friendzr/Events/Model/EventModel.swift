//
//  EventModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 31/08/2021.
//

import Foundation
import ObjectMapper

typealias EventsList = [EventObj]
typealias Event = EventObj

class EventsListModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [EventObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class EventModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: EventObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}


class EventObj: Mappable {
    
    var allday: Bool? = false
    var eventdate: String? = ""
    var timefrom: String? = ""
    var timeto: String? = ""
    var title: String? = ""
    var image: String? = ""
    var id: String? = ""
    var totalnumbert: Int? = 0
    var interests: InterestsObj?
    var joined: Int? = 0
    var attendees: [AttendeesObj]? = [AttendeesObj]()
    var categorie:String? = ""
    var descriptionEvent:String? = ""
    var key:Int? = 0
    var lat:String? = ""
    var lang:String? = ""
    var eventdateto:String? = ""

    
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        eventdate    <- map["eventdate"]
        allday   <- map["allday"]
        timefrom  <- map["timefrom"]
        timeto  <- map["timeto"]
        title  <- map["title"]
        image  <- map["image"]
        id  <- map["id"]
        totalnumbert  <- map["totalnumbert"]
        interests  <- map["interests"]
        joined  <- map["joined"]
        attendees  <- map["attendees"]
        categorie  <- map["categorie"]
        descriptionEvent  <- map["description"]
        key  <- map["key"]
        lat  <- map["lat"]
        lang  <- map["lang"]
        eventdateto  <- map["eventdateto"]
    }
}

class InterestsObj : Mappable {

    var name: String?
    var percentage: Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        name   <- map["name"]
        percentage  <- map["percentage"]
    }
}
