//
//  BestDescripsModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/02/2022.
//

import Foundation
import ObjectMapper

typealias BestDescripsList = [BestDescripsObj]

class BestDescripsModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [BestDescripsObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AddUserBestDescripsModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: NewBestDescripsAddedObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class BestDescripsObj : Mappable {
    
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

class NewBestDescripsAddedObj : Mappable {
    
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
