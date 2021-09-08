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
    
    static var isVerified: Bool {
        set{
            UserDefaults.standard.set(newValue, forKey: "isVerified")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: "isVerified")
        }
    }
    
    static var userId: Int {
        set{
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.integer(forKey: "userId")
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
    
//    "facebook": null,
//         "instagram": null,
//         "snapchat": null,
//         "tiktok": null,

    
    static func initUser(user:UserObj)  {
        Defaults.userId = user.id
        Defaults.Mobile = user.phoneNumber
        Defaults.userName = user.userName
        Defaults.Email = user.email
        Defaults.token = user.token
        Defaults.Image = user.userImage
    }
    
    static func deleteUserData(){
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "Mobile")
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "Email")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "Image")
        
        if let token = AccessToken.current,
           !token.isExpired {
            // User is logged in, do work such as go to next view controller.
            let fbLoginManager = LoginManager()
            fbLoginManager.logOut()
        }
        
        defaults.synchronize()
    }
    
}
