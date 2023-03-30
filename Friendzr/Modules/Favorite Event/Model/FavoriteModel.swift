//
//  FavoriteModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 27/03/2023.
//

import Foundation
import ObjectMapper


class ToggleFavoriteEventModel: Mappable {
    
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
