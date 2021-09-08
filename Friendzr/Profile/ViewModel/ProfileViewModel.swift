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
                    self.initUser(user: toAdd)
                    self.userModel.value = toAdd
                }
                print ("\(#function) List is \(String(describing: self.userModel))")
            }
        }
    }
    
    
    func initUser(user:ProfileObj)  {
        Defaults.userId = user.userid
        Defaults.Mobile = user.phoneNumber
        Defaults.userName = user.userName
        Defaults.Email = user.email
        Defaults.Image = user.userImage
        Defaults.LocationLng = user.lang
        Defaults.LocationLat = user.lat
        Defaults.bio = user.bio
        Defaults.birthdate = user.birthdate
        Defaults.gender = user.gender
        Defaults.key = user.key
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
