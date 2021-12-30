//
//  GenderbylocationModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/10/2021.
//

import Foundation
import ObjectMapper

class GenderbylocationModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: PeopleAroundMeObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
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
