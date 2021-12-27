//
//  ProfileViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import ObjectMapper
import Alamofire

class ProfileViewModel {
    
    var userModel : DynamicType<USEROBJECT> = DynamicType<USEROBJECT>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getProfileInfo() {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Account/getprofildata"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ProfileModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.initProfileCash(user: toAdd)
                    self.userModel.value = toAdd
                }
                print ("\(#function) List is \(String(describing: self.userModel))")
            }
        }
    }
    
    
    func initProfileCash(user:ProfileObj) {
        Defaults.userName = user.userName
        Defaults.Email = user.email
        Defaults.Image = user.userImage
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
//        Defaults.allowMyLocation = user.al
    }
}


public struct DynamicType<T> {
    typealias ModelEventListener = (T)->Void
    typealias Listeners = [ModelEventListener]
    
    private var listeners:Listeners = []
    var value:T? {
        didSet {
            for (_,observer) in listeners.enumerated() {
                if let value = value {
                    observer(value)
                }
            }
            
        }
    }
    
    
    mutating func bind(_ listener:@escaping ModelEventListener) {
        listeners.append(listener)
        if let value = value {
            listener(value)
        }
    }
    
}
