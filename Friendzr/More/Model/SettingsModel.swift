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
    
    var ghostmode: Bool?
    var pushnotification: Bool?
    var allowmylocation: Bool?
    var allowmylocationtype: Int?
    var agefrom: Int?
    var ageto: Int?
    var filteringaccordingtoage:Bool?
    var manualdistancecontrol: Double?

    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        ghostmode    <- map["ghostmode"]
        pushnotification   <- map["pushnotification"]
        allowmylocation  <- map["allowmylocation"]
        allowmylocationtype  <- map["allowmylocationtype"]
        agefrom  <- map["agefrom"]
        ageto  <- map["ageto"]
        filteringaccordingtoage  <- map["filteringaccordingtoage"]
        manualdistancecontrol  <- map["manualdistancecontrol"]
    }
}
