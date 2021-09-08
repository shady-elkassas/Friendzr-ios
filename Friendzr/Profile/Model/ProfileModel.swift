//
//  ProfileModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import ObjectMapper

typealias USEROBJECT = ProfileObj

class ProfileModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: ProfileObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class ProfileObj: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userid <- map["userid"]
        userImage <- map["userImage"]
        phoneNumber <- map["phoneNumber"]
        email <- map["email"]
        userName <- map["userName"]
        code <- map["code"]
        generatedusername <- map["generatedusername"]
        bio <- map["bio"]
        gender <- map["gender"]
        birthdate <- map["birthdate"]
        linkAccountmodel <- map["linkAccountmodel"]
        listoftagsmodel <- map["listoftagsmodel"]
        facebook <- map["facebook"]
        instagram <- map["instagram"]
        snapchat <- map["snapchat"]
        tiktok <- map["tiktok"]
        key <- map["key"]
        lang <- map["lang"]
        lat <- map["lat"]
    }
    
    
    var userid = 0
    var userImage = ""
    var phoneNumber = ""
    var email = ""
    var userName = ""
    var code = ""
    var generatedusername = ""
    var bio = ""
    var gender = ""
    var birthdate = ""
    var linkAccountmodel:LinkAccountModel? = nil
    var listoftagsmodel:TagsModel? = nil
    var facebook = ""
    var instagram = ""
    var snapchat = ""
    var tiktok = ""
    var key = ""
    var lang = ""
    var lat = ""
}

class ChangeMobileModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: UserObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class ChangePasswordModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: UserObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class LogoutModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: UserObj? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}
