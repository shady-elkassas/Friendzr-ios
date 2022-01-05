//
//  InterestsModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/09/2021.
//

import Foundation
import ObjectMapper

typealias InterestsList = [InterestObj]

class InterestsModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [InterestObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AddUserInterestModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: InterestObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class InterestObj : Mappable {
    
    var id: String? = ""
    var name: String? = ""
    
    var isSelected: Bool = false
    
    required init?(map: Map) {
    }
    
    init() {
        
    }
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        name   <- map["name"]
    }
}
