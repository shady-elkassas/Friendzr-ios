//
//  CommunityModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 30/08/2022.
//

import Foundation
import ObjectMapper

typealias RecommendedPeople = RecommendedPeopleObj
typealias RecommendedEvent = RecommendedEventObj
typealias RecentlyConnected = RecentlyConnectedModel


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
    var imageIsVerified:Bool? = false
    
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
        imageIsVerified    <- map["imageIsVerified"]
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
    var eventtypecolor:String? = ""
    var eventtype:String? = ""
    var eventColor:String? = ""

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
        eventtypecolor  <- map["eventtypecolor"]
        eventtype  <- map["eventtype"]
        eventColor  <- map["eventColor"]
    }
}

class RecentlyConnectedResponse:Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: RecentlyConnectedModel? = nil
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class RecentlyConnectedModel:Mappable {
    
    var pageNumber: Int?
    var pageSize: Int?
    var totalPages:Int? = 0
    var totalRecords:Int? = 0
    var data: [RecentlyConnectedObj]? = []

    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        pageNumber    <- map["pageNumber"]
        pageSize   <- map["pageSize"]
        totalPages  <- map["totalPages"]
        totalRecords  <- map["totalRecords"]
        data  <- map["data"]
    }
}

class RecentlyConnectedObj: NSObject,Mappable {
    
    var userId: String? = ""
    var name: String? = ""
    var image: String? = ""
    var date: String? = ""
    var imageIsVerified:Bool = false

    required init?(map: Map) {
    }
    
    override init() {
        super.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        userId    <- map["userId"]
        name   <- map["name"]
        image  <- map["image"]
        date  <- map["date"]
        imageIsVerified    <- map["imageIsVerified"]
    }
}
