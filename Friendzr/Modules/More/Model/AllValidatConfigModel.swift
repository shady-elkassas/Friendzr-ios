//
//  AllValidatConfigModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/03/2022.
//

import Foundation
import ObjectMapper

class AllValidatConfigModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: AllValidatConfigObj?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class AllValidatConfigObj: Mappable {
    
    var userName_MaxLength: Int?
    var userName_MinLength: Int?
    var userIAM_MaxLength: Int?
    var userIAM_MinLength: Int?
    var userIPreferTo_MaxLength: Int?
    var userIPreferTo_MinLength: Int?
    var password_MaxLength: Int?
    var password_MinLength: Int?
    var password_MinNumbers: Int?
    var password_MaxNumbers: Int?
    var password_MaxSpecialCharacters: Int?
    var password_MinSpecialCharacters: Int?
    var userMinAge: Int?
    var userMaxAge: Int?
    var userBio_MaxLength: Int?
    var userBio_MinLength: Int?
    var eventDetailsDescription_MinLength: Int?
    var eventDetailsDescription_MaxLength: Int?
    var eventTitle_MinLength: Int?
    var eventTitle_MaxLength: Int?
    var eventTimeValidation_MinLength: Double?
    var eventTimeValidation_MaxLength: Double?
    var eventCreationLimitNumber_MinLength: Int?
    var eventCreationLimitNumber_MaxLength: Int?
    var userTagM_MaxNumber: Int?
    var userTagM_MinNumber: Int?
    var ageFiltering_Min: Int?
    var ageFiltering_Max: Int?
    var distanceFiltering_Min: Double?
    var distanceFiltering_Max: Double?
    var distanceShowNearbyAccountsInFeed_Min: Int?
    var distanceShowNearbyAccountsInFeed_Max: Int?
    var distanceShowNearbyEvents_Min: Int?
    var distanceShowNearbyEvents_Max: Int?
    var distanceShowNearbyEventsOnMap_Min: Int?
    var distanceShowNearbyEventsOnMap_Max: Int?
    var name: String?
    var isActive: Bool?
    var id: String?

    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        userName_MaxLength    <- map["userName_MaxLength"]
        userName_MinLength   <- map["userName_MinLength"]
        userIAM_MaxLength  <- map["userIAM_MaxLength"]
        userIAM_MinLength  <- map["userIAM_MinLength"]
        userIPreferTo_MaxLength  <- map["userIPreferTo_MaxLength"]
        userIPreferTo_MinLength  <- map["userIPreferTo_MinLength"]
        password_MaxLength  <- map["password_MaxLength"]
        password_MinLength  <- map["password_MinLength"]
        password_MinNumbers  <- map["password_MinNumbers"]
        password_MaxNumbers  <- map["password_MaxNumbers"]
        password_MaxSpecialCharacters  <- map["password_MaxSpecialCharacters"]
        password_MinSpecialCharacters  <- map["password_MinSpecialCharacters"]
        userMinAge  <- map["userMinAge"]
        userMaxAge  <- map["userMaxAge"]
        userBio_MaxLength  <- map["userBio_MaxLength"]
        userBio_MinLength  <- map["userBio_MinLength"]
        eventDetailsDescription_MinLength  <- map["eventDetailsDescription_MinLength"]
        eventDetailsDescription_MaxLength  <- map["eventDetailsDescription_MaxLength"]
        eventTitle_MinLength  <- map["eventTitle_MinLength"]
        eventTitle_MaxLength  <- map["eventTitle_MaxLength"]
        eventTimeValidation_MinLength  <- map["eventTimeValidation_MinLength"]
        eventTimeValidation_MaxLength  <- map["eventTimeValidation_MaxLength"]
        eventCreationLimitNumber_MinLength  <- map["eventCreationLimitNumber_MinLength"]
        eventCreationLimitNumber_MaxLength  <- map["eventCreationLimitNumber_MaxLength"]
        userTagM_MaxNumber  <- map["userTagM_MaxNumber"]
        userTagM_MinNumber  <- map["userTagM_MinNumber"]
        ageFiltering_Min  <- map["ageFiltering_Min"]
        ageFiltering_Max  <- map["ageFiltering_Max"]
        distanceFiltering_Min  <- map["distanceFiltering_Min"]
        distanceFiltering_Max  <- map["distanceFiltering_Max"]
        distanceShowNearbyAccountsInFeed_Min  <- map["distanceShowNearbyAccountsInFeed_Min"]
        distanceShowNearbyAccountsInFeed_Max  <- map["distanceShowNearbyAccountsInFeed_Max"]
        distanceShowNearbyEvents_Min  <- map["distanceShowNearbyEvents_Min"]
        distanceShowNearbyEvents_Max  <- map["distanceShowNearbyEvents_Max"]
        distanceShowNearbyEventsOnMap_Min  <- map["distanceShowNearbyEventsOnMap_Min"]
        distanceShowNearbyEventsOnMap_Max  <- map["distanceShowNearbyEventsOnMap_Max"]
        name  <- map["name"]
        isActive  <- map["isActive"]
        id  <- map["id"]
    }
}
