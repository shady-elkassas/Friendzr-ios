//
//  SocialMediaRegisterViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 13/09/2021.
//

import Foundation
import Alamofire
import ObjectMapper

class SocialMediaRegisterViewModel {
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    // create a method for calling api which is return a Observable
    //MARK:- Social Media
    func socialMediaRegisterUser(withSocialMediaId socialMediaId:String,AndEmail email:String,username:String,completion: @escaping (_ error: String?, _ data: UserObj?) -> ()) {
        
        let url = URLs.baseURLFirst + "Authenticat/register"
        let parameters:[String : Any] = ["UserId":socialMediaId,"email": email,"logintype":1,"FcmToken":Defaults.fcmToken,"username":username,"Password":"Password1234"]
        
        let headers = RequestComponent.headerComponent([.type])
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { data, error in
            guard let userResponse = Mapper<LoginModel>().map(JSON: data!) else {
                self.errorMsg = error!
                completion(self.errorMsg, nil)
                return
            }
            if let error = error {
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
