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
    var status:Int?

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        status  <- map["status"]
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
        age <- map["age"]
        needUpdate <- map["needUpdate"]
        otherGenderName <- map["otherGenderName"]
        frindRequestNumber <- map["frindRequestNumber"]
        allowmylocation <- map["allowmylocation"]
        myAppearanceTypes <- map["myAppearanceTypes"]
        ghostmode <- map["ghostmode"]
        pushnotification <- map["pushnotification"]
        prefertoList <- map["prefertoList"]
        iamList <- map["iamList"]
        personalSpace <- map["personalSpace"]
        notificationcount <- map["notificationcount"]
        message_Count <- map["message_Count"]
        isWhiteLable <- map["isWhiteLable"]
        universityCode <- map["universityCode"]
        userImages <- map["userImages"]
    }
    
    
    var userid = ""
    var userImage = ""
    var phoneNumber = ""
    var email = ""
    var userName = ""
    var code = ""
    var displayedUserName = ""
    var bio = ""
    var gender = ""
    var birthdate = ""
    var linkAccountmodel:LinkAccountModel? = nil
    var listoftagsmodel:[TagsModel]? = nil
    var iamList:[TagsModel]? = nil
    var prefertoList:[TagsModel]? = nil
    var facebook = ""
    var instagram = ""
    var snapchat = ""
    var tiktok = ""
    var key = ""
    var lang = ""
    var lat = ""
    var age = 0
    var needUpdate = 0
    var otherGenderName: String = ""
    var frindRequestNumber:Int = 0
    var allowmylocation:Bool = false
    var myAppearanceTypes:[Int] = []
    var ghostmode:Bool = false
    var pushnotification:Bool = false
    var personalSpace:Bool = false
    var notificationcount:Int = 0
    var message_Count:Int = 0
    var isWhiteLable:Bool = false
    var universityCode:String = ""
    var userImages:[String] = [String]()
}


class UserImagesModel: Mappable {
    
    var isSuccessful: Bool? = false
    var message: String? = ""
    var data: Bool? = false
    var status:Int? = 0

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
        status  <- map["status"]
    }
}
