//
//  PreferToModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/02/2022.
//

import Foundation
import ObjectMapper

typealias PreferToList = [PreferToObj]

class PreferToModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [PreferToObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AddUserPreferToModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: NewPreferToAddedObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class PreferToObj : Mappable {
    
    var id: String? = ""
    var name: String? = ""
    var isSharedForAll:Bool? = false
    
    var isSelected: Bool = false
    
    required init?(map: Map) {
    }
    
    init() {
        
    }
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        name   <- map["name"]
        isSharedForAll   <- map["isSharedForAll"]
    }
}

class NewPreferToAddedObj : Mappable {
    
    var entityId: String? = ""
    var name: String? = ""
    
    var isSelected: Bool = false
    
    required init?(map: Map) {
    }
    
    init() {
        
    }
    // Mappable
    func mapping(map: Map) {
        entityId    <- map["entityId"]
        name   <- map["name"]
    }
}
