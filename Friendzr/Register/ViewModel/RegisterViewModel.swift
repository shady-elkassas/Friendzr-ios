//
//  RegisterViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class RegisterViewModel {
    
    // Initialise ViewModel's
    let userNameViewModel = UserNameViewModel()
    let emailViewModel = EmailViewModel()
    let passwordViewModel = PasswordViewModel()
    let confirmPasswordViewModel = ConfirmPasswordViewModel()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateRegisterCredentials() -> Bool{
        
        isSuccess =  userNameViewModel.validateCredentials() && emailViewModel.validateCredentials() && passwordViewModel.validateCredentials() && confirmPasswordViewModel.validateCredentials() && confirmPasswordViewModel.validateConfirmation(fstPass: passwordViewModel.data)
        
        errorMsg = "\(userNameViewModel.errorValue ?? "")\(passwordViewModel.errorValue ?? "")\(emailViewModel.errorValue ?? "") \(confirmPasswordViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Register
    func RegisterNewUser(withUserName userName:String,AndEmail email:String, password: String,confirmPassword:String,completion: @escaping (_ error: String?, _ data: UserObj?) -> ()) {
        
        userNameViewModel.data = userName
        emailViewModel.data = email
        passwordViewModel.data = password
        confirmPasswordViewModel.data = confirmPassword

        guard validateRegisterCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Authenticat/register"
        let headers = RequestComponent.headerComponent([.type])
        let parameters:[String : Any] = ["UserName": userName,"Email":email,"Password":password]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
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


private func generateBoundaryString() -> String {
    return "Boundary-\(UUID().uuidString)"
}

private func mimeType(for path: String) -> String {
    let url = URL(fileURLWithPath: path)
    let pathExtension = url.pathExtension
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
        if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimetype as String
        }
    }
    return "application/octet-stream"
}