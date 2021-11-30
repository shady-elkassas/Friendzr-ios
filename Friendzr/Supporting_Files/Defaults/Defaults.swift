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
    
    static var allowMyLocation: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "allowMyLocation")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "allowMyLocation")
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
    
    static var isFirstFilter: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isFirstFilter")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isFirstFilter")
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
//        Defaults.LocationLng = user.lang
//        Defaults.LocationLat = user.lat
        Defaults.age = user.age
        Defaults.userId = user.userid
        Defaults.needUpdate = user.needUpdate
        Defaults.allowMyLocation = user.allowmylocation
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

        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
        }
        
        defaults.synchronize()
    }
    
}
