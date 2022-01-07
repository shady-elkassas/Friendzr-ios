//
//  ForgetPasswordViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
//import Alamofire
import ObjectMapper

class ForgetPasswordViewModel {
    
    // Initialise ViewModel's
    let emailViewModel = EmailViewModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateResetPasswordCredentials() -> Bool{
        isSuccess =  emailViewModel.validateCredentials()
        errorMsg = "\(emailViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    //MARK:- Reset Password Request
    func ResetPassword(withEmail email:String,completion: @escaping (_ error: String?, _ data: UserObj?) -> ()) {
        CancelRequest.currentTask = false
        emailViewModel.data = email
        
        guard validateResetPasswordCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Authenticat/ForgotPassword"
        let parameters:[String : Any] = ["email": email]
        let headers = RequestComponent.headerComponent([.type,.lang])

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
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
                    completion(nil,toAdd)
                }
            }
        }
    }
}
