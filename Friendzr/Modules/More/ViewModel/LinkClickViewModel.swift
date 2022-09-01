//
//  LinkClickViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 04/08/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class LinkClickViewModel {
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func linkClickRequest(Key:String ,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Account/LinkClick"
        let parameters:[String : Any] = ["Key": Key]
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<LinkClickModel>().map(JSON: data!) else {
                self.errorMsg = error!
                completion(self.errorMsg, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg = error
                completion(self.errorMsg, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    print("toAdd ::: \(toAdd)")
                    completion(nil,toAdd)
                }
            }
        }
    }
}
