//
//  EventModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 31/08/2021.
//

import Foundation
import ObjectMapper

typealias EventsList = EventsDataModel
typealias Event = EventObj
typealias EventsInLocations = [EventObj]

class EventsListModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: EventsDataModel? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class EventsDataModel: Mappable {
    
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

class EventModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: EventObj? = nil
    var status:Int?
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        status  <- map["status"]
    }
}

class EventsListByLocationModel : Mappable {
    
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

class EventObj: NSObject,Mappable {
    
    var allday: Bool? = false
    var eventdate: String? = ""
    var timefrom: String? = ""
    var timeto: String? = ""
    var datetext:String? = ""
    var timetext:String? = ""
    var title: String? = ""
    var image: String? = ""
    var id: String? = ""
    var totalnumbert: Int? = 0
    var interestStatistic:[InterestsObj]?
    var genderStatistic:[GenderObj]?
    var joined: Int? = 0
    var attendees: [UserConversationModel]? = [UserConversationModel]()
    var categorie:String? = ""
    var category:String? = ""
    var descriptionEvent:String? = ""
    var key:Int? = 0
    var lat:String? = ""
    var lang:String? = ""
    var eventdateto:String? = ""
    var categorieimage:String? = ""
    var categorieid:Int? = 0
    var eventtypecolor:String? = ""
    var eventColor:String? = ""
    var leveevent:Int? = 0
    var encryptedID:String = ""
    var eventtype:String = ""
    var eventtypeid:String = ""
    var showAttendees:Bool = false
    var checkout_details:String = ""
    var eventHasExpired:Bool = false
    var isSendEvent:Bool = false
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        eventdate    <- map["eventdate"]
        eventtypeid    <- map["eventtypeid"]
        eventtypecolor    <- map["eventtypecolor"]
        eventColor    <- map["eventColor"]
        category    <- map["category"]
        datetext    <- map["datetext"]
        categorieimage    <- map["categorieimage"]
        categorieid    <- map["categorieid"]
        allday   <- map["allday"]
        timefrom  <- map["timefrom"]
        timeto  <- map["timeto"]
        title  <- map["title"]
        image  <- map["image"]
        id  <- map["id"]
        totalnumbert  <- map["totalnumbert"]
        interestStatistic  <- map["interestStatistic"]
        joined  <- map["joined"]
        attendees  <- map["attendees"]
        categorie  <- map["categorie"]
        descriptionEvent  <- map["description"]
        key  <- map["key"]
        lat  <- map["lat"]
        lang  <- map["lang"]
        genderStatistic  <- map["genderStatistic"]
        eventdateto  <- map["eventdateto"]
        timetext <- map["timetext"]
        leveevent <- map["leveevent"]
        encryptedID <- map["encryptedID"]
        eventtype <- map["eventtype"]
        showAttendees <- map["showAttendees"]
        checkout_details <- map["checkout_details"]
        eventHasExpired <- map["eventHasExpired"]
    }
}

class InterestsObj : Mappable {
    
    var name: String?
    var interestcount: Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        name   <- map["name"]
        interestcount  <- map["count"]
    }
}

class GenderObj : Mappable {
    
    var key: String?
    var gendercount: Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        key   <- map["key"]
        gendercount  <- map["count"]
    }
}
