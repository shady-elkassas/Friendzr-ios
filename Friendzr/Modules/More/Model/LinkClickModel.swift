//
//  LinkClickModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 04/08/2022.
//

import Foundation
import ObjectMapper

class LinkClickModel: Mappable {
    
    var isSuccessful: Bool? = false
    var message: String? = ""
    var data:String? = ""
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}
