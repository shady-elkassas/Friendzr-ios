//
//  UpdateLocationViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class UpdateLocationViewModel {
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func updatelocation(ByLat lat:String,AndLng lng:String,completion: @escaping (_ error: String?, _ data: ProfileObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Account/Updatelocation"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["lat": lat,"lang":lng]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ProfileModel>().map(JSON: data!) else {
                self.error.value = error
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.initProfileCash(user: toAdd)
                    completion(nil, toAdd)
                }
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
        Defaults.LocationLng = user.lang
        Defaults.LocationLat = user.lat
        Defaults.OtherGenderName = user.otherGenderName
        Defaults.age = user.age
        Defaults.userId = user.userid
        Defaults.needUpdate = user.needUpdate
        Defaults.notificationcount = user.notificationcount
        Defaults.message_Count = user.message_Count
        Defaults.frindRequestNumber = user.frindRequestNumber
        Defaults.interestIds.removeAll()
        for itm in user.listoftagsmodel ?? [] {
            Defaults.interestIds.append(itm.tagID)
        }
    }
}
