//
//  LoginViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
//import Alamofire
import ObjectMapper

class LoginViewModel {
    
    // Initialise ViewModel's
    let passwordViewModel = PasswordViewModel()
    let emailViewModel = EmailViewModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateLoginCredentials() -> Bool{
        isSuccess =  emailViewModel.validateCredentials() && passwordViewModel.validateCredentials()
        errorMsg = "\(passwordViewModel.errorValue ?? "")\(emailViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    //MARK:- Login request
    func LoginUser(withEmail email:String, password: String,completion: @escaping (_ error: String?, _ data: UserObj?) -> ()) {
        CancelRequest.currentTask = false
        emailViewModel.data = email
        passwordViewModel.data = password
        
        guard validateLoginCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Authenticat/login"
        
        var parameters:[String : Any] = ["email": email,"Password":password,"logintype":0,"FcmToken":Defaults.fcmToken,"platform":2]
        
        if Defaults.fcmToken == "" {
            parameters = ["email": email,"Password":password,"logintype":0,"platform":2]
        }
        
        let headers = RequestComponent.headerComponent([.type,.lang])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { data, error in
            guard let userResponse = Mapper<LoginModel>().map(JSON: data!) else {
                self.errorMsg = error!
                completion(self.errorMsg, nil)
                return
            }
            if let error = error {
                //                print ("Error while fetching data \(error)")
                self.errorMsg = error
                completion(self.errorMsg, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    print("toAdd ::: \(toAdd)")
                    Defaults.initUser(user: toAdd)
                    Defaults.isFirstOpenMap = false
                    Defaults.isFirstOpenFeed = false
                    completion(nil,toAdd)
                }
            }
        }
    }
}
