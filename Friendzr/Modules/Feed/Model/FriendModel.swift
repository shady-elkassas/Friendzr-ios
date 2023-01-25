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

class FriendObj: NSObject,Mappable {
    
    var age: Int?
    var facebook: String?
    var instagram: String?
    var snapchat: String?
    var tiktok: String?
    var userName: String?
    var displayedUserName:String?
    var userid:String? = ""
    var key:Int? = 0
    var email:String? = ""
    var userImage:String = ""
    var bio:String?
    var lang:String?
    var lat:String?
    var gender:String?
    var birthdate:String?
    var linkAccountmodel:[String]?
    var listoftagsmodel:[TagsModel]?
    var prefertoList:[TagsModel]?
    var iamList:[TagsModel]?
    var regestdata:String? = ""
    var otherGenderName:String? = ""
    var isSentRequest:Int = 0
    var userImages:[String] = [String]()
    
    required init?(map: Map) {
    }
    
    override init() {
        super.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        age    <- map["age"]
        facebook    <- map["facebook"]
        instagram    <- map["instagram"]
        snapchat    <- map["snapchat"]
        tiktok    <- map["tiktok"]
        userName    <- map["userName"]
        displayedUserName    <- map["displayedUserName"]
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
        prefertoList    <- map["prefertoList"]
        iamList    <- map["iamList"]
        regestdata    <- map["regestdata"]
        otherGenderName    <- map["otherGenderName"]
        isSentRequest    <- map["isSentRequest"]
        userImages    <- map["userImages"]
    }
}
