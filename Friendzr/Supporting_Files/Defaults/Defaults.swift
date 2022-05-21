//
//  Defaults.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

class Defaults {
    static var userName: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "userName")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "userName") ?? "Unregisterd User".localizedString
        }
    }
    
    static var token: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "token")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "token") ?? ""
        }
    }
    
    static var fcmToken: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "fcmToken")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        }
    }
    
    static var displayedUserName: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "displayedUserName")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "displayedUserName") ?? ""
        }
    }
    
    static var isVerified: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isVerified")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isVerified")
        }
    }
    
    static var darkMode: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "darkMode")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "darkMode")
        }
    }
    
    static var userId: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "userId") ?? ""
        }
    }
    
    static var Image: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "image")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "image") ?? ""
        }
    }
    
    static var Mobile: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "Mobile")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "Mobile") ?? ""
        }
    }
    
    static var appState: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "appState")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "appState") ?? ""
        }
    }
    
    static var Email: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "Email")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "Email") ?? ""
        }
    }
    
    
    static var IsFirstLaunch: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "IsFirstLaunch")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "IsFirstLaunch")
        }
    }
    
    static var interestIds: Array<String> {
        set{
            UserDefaults.standard.set(newValue, forKey: "interestIds")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.object(forKey: "interestIds") as? Array ?? []
        }
    }
    
    static var myAppearanceTypes: Array<Int> {
        set{
            UserDefaults.standard.set(newValue, forKey: "myAppearanceTypes")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.object(forKey: "myAppearanceTypes") as? Array ?? []
        }
    }
    
    static var birthdate: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "birthdate")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "birthdate") ?? ""
        }
    }
    
    static var gender: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "gender")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "gender") ?? ""
        }
    }
    
    static var OtherGenderName: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "OtherGenderName")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "OtherGenderName") ?? ""
        }
    }
    
    
    static var LocationLng: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "LocationLng")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "LocationLng") ?? ""
        }
    }
    
    
    static var LocationLat: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "LocationLat")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "LocationLat") ?? ""
        }
    }
    
    static var bio: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "bio")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "bio") ?? ""
        }
    }
    
    static var key: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "key")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "key") ?? ""
        }
    }
    
    static var needUpdate: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "needUpdate")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "needUpdate")
        }
    }
    
    static var facebook: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "facebook")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "facebook") ?? ""
        }
    }
    static var instagram: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "instagram")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "instagram") ?? ""
        }
    }
    static var snapchat: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "snapchat")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "snapchat") ?? ""
        }
    }
    
    static var tiktok: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "tiktok")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "tiktok") ?? ""
        }
    }
    
    static var age: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "age")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "age")
        }
    }
    
    static var frindRequestNumber: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "frindRequestNumber")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "frindRequestNumber")
        }
    }
    
    static var messagesInboxCountBadge: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "messagesInboxCountBadge")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "messagesInboxCountBadge")
        }
    }
    
    static var notificationcount: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "notificationcount")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "notificationcount")
        }
    }
    
    static var message_Count: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "message_Count")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "message_Count")
        }
    }
    
    static var allowMyLocation: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "allowMyLocation")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "allowMyLocation")
        }
    }
    
    static var allowMyLocationSettings: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "allowMyLocationSettings")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "allowMyLocationSettings")
        }
    }
    
    static var ghostModeEveryOne: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "ghostModeEveryOne")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "ghostModeEveryOne")
        }
    }
    
    static var ghostMode: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "ghostMode")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "ghostMode")
        }
    }
    
    static var isFirstLaunch: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isFirstLaunch")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isFirstLaunch")
        }
    }
    
    
    static var language: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "language")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "language") ?? ""
        }
    }
    
    static var availableVC: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "availableVC")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "availableVC") ?? ""
        }
    }
    
    static var ConversationID: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "ConversationID")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "ConversationID") ?? ""
        }
    }
    
    static var isFirstFilter: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isFirstFilter")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isFirstFilter")
        }
    }
    
    static var isFirstOpenMap: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isFirstOpenMap")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isFirstOpenMap")
        }
    }
    
    static var isIPhoneLessThan1500: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isIPhoneLessThan1500")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isIPhoneLessThan1500")
        }
    }
    
    static var isIPhoneLessThan2500: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isIPhoneLessThan2500")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isIPhoneLessThan2500")
        }
    }
    
    static var pushnotification: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "pushnotification")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "pushnotification")
        }
    }
    
    static var hideAds: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "hideAds")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "hideAds")
        }
    }
    
    
    static var iamid: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "iamid")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "iamid") ?? ""
        }
    }
    
    static var preferToid: String {
        set{
            UserDefaults.standard.set(newValue, forKey: "preferToid")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.string(forKey: "preferToid") ?? ""
        }
    }
    
    static var isFirstLogin: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isFirstLogin")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isFirstLogin") ?? false
        }
    }
    
    static func initUser(user:UserObj)  {
        Defaults.userName = user.userName
        Defaults.Email = user.email
        Defaults.Image = user.userImage
        Defaults.token = user.token
        Defaults.displayedUserName = user.displayedUserName
        Defaults.bio = user.bio
        Defaults.gender = user.gender
        Defaults.birthdate = user.birthdate
        Defaults.facebook = user.facebook
        Defaults.instagram = user.instagram
        Defaults.snapchat = user.snapchat
        Defaults.tiktok = user.tiktok
        Defaults.key = user.key
        Defaults.OtherGenderName = user.OtherGenderName
        Defaults.age = user.age
        Defaults.userId = user.userid
        Defaults.needUpdate = user.needUpdate
        Defaults.allowMyLocation = user.allowmylocation
        Defaults.ghostMode = user.ghostmode
        Defaults.myAppearanceTypes = user.myAppearanceTypes
        Defaults.frindRequestNumber = user.frindRequestNumber
        Defaults.pushnotification = user.pushnotification
        Defaults.notificationcount = user.notificationcount
        Defaults.message_Count = user.message_Count
    }
    
    static func deleteUserData(){
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "Mobile")
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "Email")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "Image")
        defaults.removeObject(forKey: "key")
        defaults.removeObject(forKey: "bio")
        defaults.removeObject(forKey: "gender")
        defaults.removeObject(forKey: "birthdate")
        defaults.removeObject(forKey: "interestIds")
        defaults.removeObject(forKey: "age")
        defaults.removeObject(forKey: "tiktok")
        defaults.removeObject(forKey: "snapchat")
        defaults.removeObject(forKey: "instagram")
        defaults.removeObject(forKey: "facebook")
        defaults.removeObject(forKey: "displayedUserName")
        defaults.removeObject(forKey: "needUpdate")
        defaults.removeObject(forKey: "allowMyLocation")
        defaults.removeObject(forKey: "isFirstFilter")
        defaults.removeObject(forKey: "isFirstOpenMap")
        defaults.removeObject(forKey: "OtherGenderName")
        defaults.removeObject(forKey: "myAppearanceTypes")
        defaults.removeObject(forKey: "ghostModeEveryOne")
        defaults.removeObject(forKey: "ghostMode")
        defaults.removeObject(forKey: "frindRequestNumber")
        defaults.removeObject(forKey: "fcmToken")
        defaults.removeObject(forKey: "pushnotification")
        defaults.removeObject(forKey: "notificationcount")
        defaults.removeObject(forKey: "message_Count")

        
        defaults.removeObject(forKey: "userName_MaxLength")
        defaults.removeObject(forKey: "userName_MinLength")
        defaults.removeObject(forKey: "userIAM_MaxLength")
        defaults.removeObject(forKey: "userIAM_MinLength")
        defaults.removeObject(forKey: "userIPreferTo_MaxLength")
        defaults.removeObject(forKey: "userIPreferTo_MinLength")
        defaults.removeObject(forKey: "password_MaxLength")
        defaults.removeObject(forKey: "password_MinLength")
        defaults.removeObject(forKey: "userMinAge")
        defaults.removeObject(forKey: "userMaxAge")
        defaults.removeObject(forKey: "userBio_MinLength")
        defaults.removeObject(forKey: "userBio_MaxLength")
        defaults.removeObject(forKey: "eventDetailsDescription_MinLength")
        defaults.removeObject(forKey: "eventDetailsDescription_MaxLength")
        defaults.removeObject(forKey: "eventTitle_MinLength")
        defaults.removeObject(forKey: "eventTitle_MaxLength")
        defaults.removeObject(forKey: "eventCreationLimitNumber_MinLength")
        defaults.removeObject(forKey: "eventCreationLimitNumber_MaxLength")
        defaults.removeObject(forKey: "ageFiltering_Min")
        defaults.removeObject(forKey: "userTagM_MinNumber")
        defaults.removeObject(forKey: "ageFiltering_Max")
        defaults.removeObject(forKey: "userTagM_MaxNumber")
        defaults.removeObject(forKey: "distanceFiltering_Min")
        defaults.removeObject(forKey: "distanceFiltering_Max")
        defaults.removeObject(forKey: "distanceShowNearbyAccountsInFeed_Min")
        defaults.removeObject(forKey: "distanceShowNearbyAccountsInFeed_Max")
        defaults.removeObject(forKey: "distanceShowNearbyEvents_Min")
        defaults.removeObject(forKey: "distanceShowNearbyEvents_Max")
        defaults.removeObject(forKey: "distanceShowNearbyEventsOnMap_Min")
        defaults.removeObject(forKey: "distanceShowNearbyEventsOnMap_Max")
        defaults.removeObject(forKey: "iamid")
        defaults.removeObject(forKey: "preferToid")
        defaults.removeObject(forKey: "isFirstLogin")

        
        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
        }
        
        defaults.synchronize()
    }
    
}

//AllValidatConfigObj
extension Defaults {
    
    static var userName_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userName_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userName_MaxLength")
        }
    }
    static var userName_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userName_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userName_MinLength")
        }
    }
    static var userIAM_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userIAM_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userIAM_MaxLength")
        }
    }
    static var userIAM_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userIAM_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userIAM_MinLength")
        }
    }
    static var userIPreferTo_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userIPreferTo_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userIPreferTo_MaxLength")
        }
    }
    static var userIPreferTo_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userIPreferTo_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userIPreferTo_MinLength")
        }
    }
    static var password_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "password_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "password_MaxLength")
        }
    }
    static var password_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "password_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "password_MinLength")
        }
    }
    static var password_MinNumbers: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "password_MinNumbers")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "password_MinNumbers")
        }
    }
    static var password_MaxNumbers: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "password_MaxNumbers")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "password_MaxNumbers")
        }
    }
    static var password_MaxSpecialCharacters: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "password_MaxSpecialCharacters")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "password_MaxSpecialCharacters")
        }
    }
    static var password_MinSpecialCharacters: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "password_MinSpecialCharacters")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "password_MinSpecialCharacters")
        }
    }
    static var userMinAge: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userMinAge")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userMinAge")
        }
    }
    static var userMaxAge: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userMaxAge")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userMaxAge")
        }
    }
    static var userBio_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userBio_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userBio_MaxLength")
        }
    }
    static var userBio_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userBio_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userBio_MinLength")
        }
    }
    static var eventDetailsDescription_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventDetailsDescription_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "eventDetailsDescription_MinLength")
        }
    }
    static var eventDetailsDescription_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventDetailsDescription_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "eventDetailsDescription_MaxLength")
        }
    }
    static var eventTitle_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventTitle_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "eventTitle_MinLength")
        }
    }
    static var eventTitle_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventTitle_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "eventTitle_MaxLength")
        }
    }
    static var eventTimeValidation_MinLength: Double {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventTimeValidation_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.double(forKey: "eventTimeValidation_MinLength")
        }
    }
    static var eventTimeValidation_MaxLength: Double {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventTimeValidation_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.double(forKey: "eventTimeValidation_MaxLength")
        }
    }
    static var eventCreationLimitNumber_MinLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventCreationLimitNumber_MinLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "eventCreationLimitNumber_MinLength")
        }
    }
    static var eventCreationLimitNumber_MaxLength: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "eventCreationLimitNumber_MaxLength")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "eventCreationLimitNumber_MaxLength")
        }
    }
    static var userTagM_MaxNumber: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userTagM_MaxNumber")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userTagM_MaxNumber")
        }
    }
    static var userTagM_MinNumber: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userTagM_MinNumber")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userTagM_MinNumber")
        }
    }
    static var ageFiltering_Min: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "ageFiltering_Min")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "ageFiltering_Min")
        }
    }
    static var ageFiltering_Max: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "ageFiltering_Max")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "ageFiltering_Max")
        }
    }
    static var distanceFiltering_Min: Double {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceFiltering_Min")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.double(forKey: "distanceFiltering_Min")
        }
    }
    static var distanceFiltering_Max: Double {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceFiltering_Max")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.double(forKey: "distanceFiltering_Max")
        }
    }
    static var distanceShowNearbyAccountsInFeed_Min: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceShowNearbyAccountsInFeed_Min")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "distanceShowNearbyAccountsInFeed_Min")
        }
    }
    static var distanceShowNearbyAccountsInFeed_Max: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceShowNearbyAccountsInFeed_Max")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "distanceShowNearbyAccountsInFeed_Max")
        }
    }
    static var distanceShowNearbyEvents_Min: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceShowNearbyEvents_Min")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "distanceShowNearbyEvents_Min")
        }
    }
    static var distanceShowNearbyEvents_Max: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceShowNearbyEvents_Max")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "distanceShowNearbyEvents_Max")
        }
    }
    static var distanceShowNearbyEventsOnMap_Min: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceShowNearbyEventsOnMap_Min")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "distanceShowNearbyEventsOnMap_Min")
        }
    }
    static var distanceShowNearbyEventsOnMap_Max: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "distanceShowNearbyEventsOnMap_Max")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "distanceShowNearbyEventsOnMap_Max")
        }
    }
    
    static func initValidationConfig(validate:AllValidatConfigObj) {
        Defaults.userName_MaxLength = validate.userName_MaxLength ?? 0
        Defaults.userName_MinLength = validate.userName_MinLength ?? 0
        Defaults.userIAM_MaxLength = validate.userIAM_MaxLength ?? 0
        Defaults.userIAM_MinLength = validate.userIAM_MinLength ?? 0
        Defaults.userIPreferTo_MaxLength = validate.userIPreferTo_MaxLength ?? 0
        Defaults.userIPreferTo_MinLength = validate.userIPreferTo_MinLength ?? 0
        Defaults.password_MaxLength = validate.password_MaxLength ?? 0
        Defaults.password_MinLength = validate.password_MinLength ?? 0
        Defaults.password_MinNumbers = validate.password_MinNumbers ?? 0
        Defaults.password_MaxNumbers = validate.password_MaxNumbers ?? 0
        Defaults.password_MaxSpecialCharacters = validate.password_MaxSpecialCharacters ?? 0
        Defaults.password_MinSpecialCharacters = validate.password_MinSpecialCharacters ?? 0
        Defaults.userMinAge = validate.userMinAge ?? 0
        Defaults.userMaxAge = validate.userMaxAge ?? 0
        Defaults.userBio_MaxLength = validate.userBio_MaxLength ?? 0
        Defaults.userBio_MinLength = validate.userBio_MinLength ?? 0
        Defaults.eventDetailsDescription_MinLength = validate.eventDetailsDescription_MinLength ?? 0
        Defaults.eventDetailsDescription_MaxLength = validate.eventDetailsDescription_MaxLength ?? 0
        Defaults.eventTitle_MinLength = validate.eventTitle_MinLength ?? 0
        Defaults.eventTitle_MaxLength = validate.eventTitle_MaxLength ?? 0
        Defaults.eventTimeValidation_MinLength = validate.eventTimeValidation_MinLength ?? 0
        Defaults.eventTimeValidation_MaxLength = validate.eventTimeValidation_MaxLength ?? 0
        Defaults.eventCreationLimitNumber_MinLength = validate.eventCreationLimitNumber_MinLength ?? 0
        Defaults.eventCreationLimitNumber_MaxLength = validate.eventCreationLimitNumber_MaxLength ?? 0
        Defaults.userTagM_MaxNumber = validate.userTagM_MaxNumber ?? 0
        Defaults.userTagM_MinNumber = validate.userTagM_MinNumber ?? 0
        Defaults.ageFiltering_Min = validate.ageFiltering_Min ?? 0
        Defaults.ageFiltering_Max = validate.ageFiltering_Max ?? 0
        Defaults.distanceFiltering_Min = validate.distanceFiltering_Min ?? 0
        Defaults.distanceFiltering_Max = validate.distanceFiltering_Max ?? 0
        Defaults.distanceShowNearbyAccountsInFeed_Min = validate.distanceShowNearbyAccountsInFeed_Min ?? 0
        Defaults.distanceShowNearbyAccountsInFeed_Max = validate.distanceShowNearbyAccountsInFeed_Max ?? 0
        Defaults.distanceShowNearbyEvents_Min = validate.distanceShowNearbyEvents_Min ?? 0
        Defaults.distanceShowNearbyEvents_Max = validate.distanceShowNearbyEvents_Max ?? 0
        Defaults.distanceShowNearbyEventsOnMap_Min = validate.distanceShowNearbyEventsOnMap_Min ?? 0
        Defaults.distanceShowNearbyEventsOnMap_Max = validate.distanceShowNearbyEventsOnMap_Max ?? 0
    }
}
