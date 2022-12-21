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
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])

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
        Defaults.OtherGenderName = user.otherGenderName
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
//        Defaults.isWhiteLable = user.isWhiteLable
        Defaults.universityCode = user.universityCode

        Defaults.interestIds.removeAll()
        for item in user.listoftagsmodel ?? [] {
            Defaults.interestIds.append(item.tagID)
        }
    }
}
