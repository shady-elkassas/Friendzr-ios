//
//  InterestsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class InterestsViewModel {
    
    var interests : DynamicType<InterestsList> = DynamicType<InterestsList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllInterests(completion: @escaping (_ error: String?, _ data: [InterestObj]?) -> ())  {
        let url = URLs.baseURLFirst + "Events/GetAllInterests"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let nodesResponse = Mapper<InterestsModel>().map(JSON: data!) else {
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
                if let toAdd = nodesResponse.data {
                    print("toAdd ::: \(toAdd)")
                    completion(nil,toAdd)
                }
            }
        }
    }
}
