//
//  RequestFriendStatusViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 13/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class RequestFriendStatusViewModel {
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    //add Request Friend Status
    func
    requestFriendStatus(withID id:String,AndKey key:Int,requestdate:String,completion: @escaping (_ error: String?, _ data: Bool?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "FrindRequest/RequestFriendStatus"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["userid": id,"key":key,"Requestdate":requestdate]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<FriendModel>().map(JSON: data!) else {
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
                if let toAdd = userResponse.isSuccessful {
                    completion(nil, toAdd)
                }
            }
        }
    }
}
