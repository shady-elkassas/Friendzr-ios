//
//  EditProfileViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
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
    func editProfile(withUserName userName:String,AndEmail email:String,AndGender gender:String,AndGeneratedUserName generatedUserName:String,AndBio bio:String,AndBirthdate birthdate:String,AndUserImage userImage:String,tagsId:[String],completion: @escaping (_ error: String?, _ data: ProfileObj?) -> ()) {
        
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
        let parms:[String:Any] = ["Gender":gender,"bio":bio,"birthdate":birthdate,"Username":userName,"Email":email,"listoftags":tagsId]
        
//        if attachedImg {
//            guard let urlRequest = URL(string: url) else { return }
//            var request = URLRequest(url: urlRequest)
//            var body = Data()
//            let boundary = generateBoundaryString()
//            headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
//            let imageData = userImage.jpegData(compressionQuality: 0.5)
//            body.append(imageData!)
//
//            let session = URLSession.shared
//            session.dataTask(with: request) { (data, response, error) in
//                if let response = response {
//                    print(response)
//                }
//
//                if let data = data {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data, options: [])
//                        print(json)
//                    } catch {
//                        print(error)
//                    }
//                }
//            }
//        }else {
            RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parms, andHeaders: headers) { (data,error) in

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
//        }
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
}
