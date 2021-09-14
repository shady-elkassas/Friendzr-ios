//
//  FriendModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 12/09/2021.
//

import Foundation
import ObjectMapper

class FriendModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: FriendObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class FriendObj: Mappable {
    
    var age: Int?
    var facebook: String?
    var instagram: String?
    var snapchat: String?
    var tiktok: String?
    var userName: String?
    var generatedusername:String?
    var userid:String?
    var key:Int?
    var email:String?
    var userImage:String?
    var bio:String?
    var lang:String?
    var lat:String?
    var gender:String?
    var birthdate:String?
    var linkAccountmodel:[String]?
    var listoftagsmodel:[TagsModel]?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        age    <- map["age"]
        facebook    <- map["facebook"]
        instagram    <- map["instagram"]
        snapchat    <- map["snapchat"]
        tiktok    <- map["tiktok"]
        userName    <- map["userName"]
        generatedusername    <- map["generatedusername"]
        userid    <- map["userid"]
        key    <- map["key"]
        email    <- map["email"]
        userImage    <- map["userImage"]
        bio    <- map["bio"]
        lang    <- map["lang"]
        lat    <- map["lat"]
        gender    <- map["gender"]
        birthdate    <- map["birthdate"]
        linkAccountmodel    <- map["linkAccountmodel"]
        listoftagsmodel    <- map["listoftagsmodel"]
    }
}
