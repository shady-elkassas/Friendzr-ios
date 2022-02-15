//
//  SettingsModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 20/09/2021.
//

import Foundation
import ObjectMapper


class SettingsModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: SettingsObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class SettingsObj: Mappable {
    
    var ghostmode: Bool? = false
    var pushnotification: Bool? = false
    var personalSpace: Bool? = false
    var allowmylocation: Bool? = false
    var myAppearanceTypes: [Int]? = [Int]()
    var agefrom: Int? = 0
    var ageto: Int? = 0
    var filteringaccordingtoage:Bool? = false
    var manualdistancecontrol: Double? = 0
    var distanceFilter:Bool? = false
    var language:String? = ""
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        ghostmode    <- map["ghostmode"]
        pushnotification   <- map["pushnotification"]
        allowmylocation  <- map["allowmylocation"]
        myAppearanceTypes  <- map["myAppearanceTypes"]
        agefrom  <- map["agefrom"]
        ageto  <- map["ageto"]
        filteringaccordingtoage  <- map["filteringaccordingtoage"]
        manualdistancecontrol  <- map["manualdistancecontrol"]
        distanceFilter  <- map["distanceFilter"]
        language  <- map["language"]
        personalSpace  <- map["personalSpace"]        
    }
}


class DeleteAccountModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}
