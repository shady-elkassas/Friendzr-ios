//
//  IamModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/02/2022.
//

import Foundation
import ObjectMapper

typealias IamList = [IamObj]

class IamModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [IamObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AddUserIamModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: NewIamAddedObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class IamObj : Mappable {
    
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

class NewIamAddedObj : Mappable {
    
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
