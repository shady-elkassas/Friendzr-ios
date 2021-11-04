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
        
        let url = URLs.baseURLFirst + "Account/Updatelocation"
        let headers = RequestComponent.headerComponent([.authorization,.type])
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
                    completion(nil, toAdd)
                }
            }
        }
    }
}
