//
//  ChangePasswordViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire


class ChangePasswordViewModel {
    
    var changePasswordModel : UserObj? = nil
    
    // Initialise ViewModel's
    let oldPasswordViewModel = PasswordViewModel()
    let newPasswordViewModel = PasswordViewModel()
    let confirmNewPasswordViewModel = ConfirmPasswordViewModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateChangePasswordCredentials() -> Bool{
        
        isSuccess =  oldPasswordViewModel.validateCredentials() && newPasswordViewModel.validateCredentials()
            && confirmNewPasswordViewModel.validateCredentials() && confirmNewPasswordViewModel.validateConfirmation(fstPass: newPasswordViewModel.data)
        errorMsg = "\(oldPasswordViewModel.errorValue ?? "")\(newPasswordViewModel.errorValue ?? "")) \(confirmNewPasswordViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    func changePasswordRequest(witholdPassword oldPassword:String, AndNewPassword newPassword: String,AndConfirmNewPassword confirmNewPassword :String ,completion: @escaping (_ error: String?, _ data: UserObj?) -> ()) {
        
        oldPasswordViewModel.data = oldPassword
        newPasswordViewModel.data = newPassword
        confirmNewPasswordViewModel.data = confirmNewPassword
        
        guard validateChangePasswordCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Account/changepass"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters = "oldPassword=\(oldPassword)&newPassword=\(newPassword)".data(using: .utf8)
        
        if confirmNewPassword != newPassword {
            self.errorMsg = confirmNewPasswordViewModel.confirmErrorMessage
            completion(self.errorMsg, nil)
            return
        }
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let changePasswordResponse = Mapper<ChangePasswordModel>().map(JSON: data!) else {
                self.errorMsg = error ?? ""
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
                if let toAdd = changePasswordResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
