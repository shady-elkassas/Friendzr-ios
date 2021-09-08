//
//  CheckUserNameViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class CheckUserNameViewModel {
    
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    //MARK:- Register
    
    func checkUserName(withUserName userName:String,completion: @escaping (_ error: String?, _ data: UserObj?) -> ()) {
        
        let url = URLs.baseURLFirst + "Authenticat/CheckUserName?UserName=\(userName)"
        let headers = RequestComponent.headerComponent([.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<LoginModel>().map(JSON: data!) else {
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
                    completion(nil,toAdd)
                }
            }
        }
    }
}
