//
//  RequestsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class RequestsViewModel {
    
    var requests : DynamicType<UsersList> = DynamicType<UsersList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    //Get All Requests
    func getAllRequests() {
        
        let url = URLs.baseURLFirst + "FrindRequest/Allrequest?pageNumber=\(0)&pageSize=\(100)"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<FeedModel>().map(JSON: data!) else {
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
                    self.requests.value = toAdd
                }
            }
        }
    }
}
