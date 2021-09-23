//
//  SettingsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 20/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class SettingsViewModel {
    
    var userSettings : DynamicType<SettingsObj> = DynamicType<SettingsObj>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg :DynamicType<String> = DynamicType()
    
    func getUserSetting() {
        
        let url = URLs.baseURLFirst + "Account/UserSetting"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let settingsResponse = Mapper<SettingsModel>().map(JSON: data!) else {
                self.errorMsg.value = error ?? ""
                return
            }
            
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = settingsResponse.data {
                    self.userSettings.value = toAdd
                }
            }
        }
    }
    
    
    func updatUserSetting(withPushNotification pushNotification:Bool, AndAllowMyLocation allowMyLocation: Bool,AndGhostMode ghostMode :Bool,allowmylocationtype:Int ,completion: @escaping (_ error: String?, _ data: SettingsObj?) -> ()) {
        
        let url = URLs.baseURLFirst + "Account/updatSetting"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["pushnotification": pushNotification,"allowmylocation":allowMyLocation,"ghostmode":ghostMode,"allowmylocationtype":allowmylocationtype]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let settingsResponse = Mapper<SettingsModel>().map(JSON: data!) else {
                self.errorMsg.value = error ?? ""
                completion(self.errorMsg.value, nil)
                return
            }
            
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = settingsResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    
    func deleteAccount(_ completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        let url = URLs.baseURLFirst + "Account/DeleteAccount"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let settingsResponse = Mapper<SettingsModel>().map(JSON: data!) else {
                self.errorMsg.value = error ?? ""
                completion(self.errorMsg.value, nil)
                return
            }
            
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
                completion(self.errorMsg.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = settingsResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
