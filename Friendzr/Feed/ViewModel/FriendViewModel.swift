//
//  FriendViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 12/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class FriendViewModel {
    
    var model : DynamicType<FriendObj> = DynamicType<FriendObj>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getFriendDetails(ById id:String) {
        let url = URLs.baseURLFirst + "FrindRequest/Userprofil"
        
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["userid": id]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<FriendModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.model.value = toAdd
                }
            }
        }
    }
}
