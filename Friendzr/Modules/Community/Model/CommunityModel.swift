//
//  CommunityModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 30/08/2022.
//

import Foundation
import ObjectMapper

typealias RecommendedPeople = RecommendedPeopleObj
typealias RecommendedEvent = RecommendedEventObj

class RecommendedPeopleModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: RecommendedPeopleObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class RecommendedPeopleObj: Mappable {
    
    var userId: String? = ""
    var name: String? = ""
    var image: String? = ""
    var interestMatchPercent: Double? = 0.0
    var distanceFromYou: Double? = 0.0
    var matchedInterests: [String]? = []
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        userId    <- map["userId"]
        name   <- map["name"]
        image  <- map["image"]
        interestMatchPercent  <- map["interestMatchPercent"]
        distanceFromYou  <- map["distanceFromYou"]
        matchedInterests  <- map["matchedInterests"]
    }
}


class RecommendedEventModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: RecommendedEventObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class RecommendedEventObj: Mappable {
    
    var eventId: String? = ""
    var title: String? = ""
    var descriptionEvent: String? = ""
    var image: String? = ""
    var attendees: Int? = 0
    var from: Int? = 0
    var eventDate: String? = ""

    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        eventId    <- map["eventId"]
        title   <- map["title"]
        descriptionEvent  <- map["description"]
        image  <- map["image"]
        attendees  <- map["attendees"]
        from  <- map["from"]
        eventDate  <- map["eventDate"]
    }
}
