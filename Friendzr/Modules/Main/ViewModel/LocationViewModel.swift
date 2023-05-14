//
//  LocationViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 26/04/2023.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire
import SwiftUI

class LocationViewModel {
    
    var liveLocationDet : DynamicType<liveLocationobj> = DynamicType<liveLocationobj>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func updateLiveLoction(WithID id:String, completion: @escaping (_ error: String?, _ data: Bool?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/UpdateLiveLocation"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["id":id,"latitude":Defaults.LocationLat,"longitude":Defaults.LocationLng,"locationName":""]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<UpdateLocationModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func stopLiveLocation(WithID id:String, completion: @escaping (_ error: String?, _ data: Bool?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/StopLiveLocation"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["id":id]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<UpdateLocationModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func getLiveLocation(WithID id:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/GetLiveLocation?id=\(id)"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
//        let parameters:[String : Any] = ["id":id]
        
        RequestManager().request(fromUrl: url, byMethod: "GET", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<LiveLocationResponse>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.liveLocationDet.value = toAdd
                }
            }
        }
    }
}
