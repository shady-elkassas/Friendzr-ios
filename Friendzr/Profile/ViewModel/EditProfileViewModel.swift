//
//  EditProfileViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import Foundation
import ObjectMapper
import Alamofire

class EditProfileViewModel {
    
    // Initialise ViewModel's
    let userNameViewModel = UserNameViewModel()
    let emailViewModel = EmailViewModel()
    let genderViewModel = GenderViewModel()
    let bioViewModel = BioViewModel()
    let birthdateViewModel = BirthdateViewModel()
//    let userImageViewModel = UserImageViewModel()
    let generatedUserNameViewModel = GeneratedUserNameViewModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateEditProfileCredentials() -> Bool{
        isSuccess =  userNameViewModel.validateCredentials() && emailViewModel.validateCredentials() && genderViewModel.validateCredentials() && bioViewModel.validateCredentials() && birthdateViewModel.validateCredentials() && /*userImageViewModel.validateCredentials() &&*/ generatedUserNameViewModel.validateCredentials()
        
        errorMsg = "\(userNameViewModel.errorValue ?? "")\(emailViewModel.errorValue ?? "")\(genderViewModel.errorValue ?? "")\(bioViewModel.errorValue ?? "")\(birthdateViewModel.errorValue ?? "")\(generatedUserNameViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Edit Profile
    func editProfile(withUserName userName:String,AndEmail email:String,AndGender gender:String,AndGeneratedUserName generatedUserName:String,AndBio bio:String,AndBirthdate birthdate:String,AndUserImage userImage:String,tagsId:[Int],completion: @escaping (_ error: String?, _ data: ProfileObj?) -> ()) {
        
        userNameViewModel.data = userName
        emailViewModel.data = email
        genderViewModel.data = gender
        bioViewModel.data = bio
        birthdateViewModel.data = birthdate
//        userImageViewModel.data = userImage
        generatedUserNameViewModel.data = generatedUserName

        guard validateEditProfileCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Account/update"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let bodyData = "Gender=\(gender)&bio=\(bio)&birthdate=\(birthdate)&Username=\(userName)&Email=\(email)&listoftags=\(tagsId)".data(using: .utf8)
        print(String(data: bodyData!, encoding: .utf8)!)
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: bodyData, andHeaders: headers) { (data,error) in

            guard let userResponse = Mapper<ProfileModel>().map(JSON: data!) else {
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
