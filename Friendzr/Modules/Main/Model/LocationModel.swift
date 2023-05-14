//
//  LocationModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 26/04/2023.
//

import Foundation
import ObjectMapper

typealias liveLocationobj = LivelocationObj


class UpdateLocationModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: Bool? = false
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class LiveLocationResponse : Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: LivelocationObj? = nil
    var status:Int?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        data  <- map["model"]
        status  <- map["status"]
    }
}

class LivelocationObj: Mappable {
    
    var id: String? = ""
    var locationName: String? = ""
    var latitude: String? = ""
    var longitude: String? = ""
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        locationName  <- map["locationName"]
        latitude  <- map["latitude"]
        longitude  <- map["longitude"]
    }
}
