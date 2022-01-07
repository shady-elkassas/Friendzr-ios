//
//  UserModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import ObjectMapper

class UserObj: Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userid <- map["userid"]
        userImage <- map["userImage"]
        phoneNumber <- map["phoneNumber"]
        email <- map["email"]
        userName <- map["userName"]
        code <- map["code"]
        token <- map["token"]
        displayedUserName <- map["displayedUserName"]
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
        needUpdate <- map["needUpdate"]
        age <- map["age"]
        allowmylocation <- map["allowmylocation"]
        myAppearanceTypes <- map["myAppearanceTypes"]
        ghostmode <- map["ghostmode"]
        pushnotification <- map["pushnotification"]
        OtherGenderName <- map["OtherGenderName"]
    }
    
    
    var userid = ""
    var userImage = ""
    var phoneNumber = ""
    var email = ""
    var userName = ""
    var code = ""
    var token = ""
    var displayedUserName = ""
    var bio = ""
    var gender = ""
    var OtherGenderName = ""
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
    var needUpdate:Int = 0
    var age:Int = 0
    var allowmylocation:Bool = false
    var myAppearanceTypes:[Int] = []
    var ghostmode:Bool = false
    var pushnotification:Bool = false
}


class LinkAccountModel : Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        linkAccountname <- map["linkAccountname"]
        linkAccounturl <- map["linkAccounturl"]
    }
    
    
    var linkAccountname = ""
    var linkAccounturl = ""
}

class TagsModel : Mappable {
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        tagname <- map["tagname"]
        tagID <- map["tagID"]
        
    }
    
    
    var tagname = ""
    var tagID = ""
}


struct LoginResponse: Codable {
    var isSuccessful: Bool
    var message: String
    var model: UserObj22
    
    enum CodingKeys: String, CodingKey {
        case isSuccessful = "isSuccessful"
        case message = "message"
        case model = "model"
    }
}

struct UserObj22: Codable {
    //    var id:String
    var userImage:String
    var phoneNumber :String
    var email:String
    var userName :String
    var code:String
    var token:String
    var generatedusername:String
    var bio:String
    var gender:String
    var birthdate:String
    //    var linkAccountmodel:LinkAccountModel? = nil
    //    var listoftagsmodel:TagsModel? = nil
    
    enum CodingKeys: String, CodingKey {
        case userImage = "userImage"
        case phoneNumber = "phoneNumber"
        case email = "email"
        case userName = "userName"
        case code = "code"
        case token = "token"
        case generatedusername = "generatedusername"
        case bio = "bio"
        case gender = "gender"
        case birthdate = "birthdate"
    }
}
