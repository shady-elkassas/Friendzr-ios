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
//    let emailViewModel = EmailViewModel()
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
        isSuccess =  userNameViewModel.validateCredentials() && genderViewModel.validateCredentials() && bioViewModel.validateCredentials() && birthdateViewModel.validateCredentials() && /*userImageViewModel.validateCredentials() &&*/ generatedUserNameViewModel.validateCredentials()
        
        errorMsg = "\(userNameViewModel.errorValue ?? "")\(genderViewModel.errorValue ?? "")\(bioViewModel.errorValue ?? "")\(birthdateViewModel.errorValue ?? "")\(generatedUserNameViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Edit Profile
    func editProfile(withUserName userName:String,AndGender gender:String,AndGeneratedUserName generatedUserName:String,AndBio bio:String,AndBirthdate birthdate:String,tagsId:[String],attachedImg:Bool,AndUserImage userImage:UIImage,completion: @escaping (_ error: String?, _ data: ProfileObj?) -> ()) {
        
        userNameViewModel.data = userName
//        emailViewModel.data = email
        genderViewModel.data = gender
        bioViewModel.data = bio
        birthdateViewModel.data = birthdate
        generatedUserNameViewModel.data = generatedUserName
        
        guard validateEditProfileCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Account/update"
//        let headers = RequestComponent.headerComponent([.type,.authorization])
        
        
        guard let dataList = try? JSONSerialization.data(withJSONObject: tagsId, options: []) else {return}
        let listoftag = String(data: dataList, encoding: String.Encoding.utf8)
//        let listoftagStr = String(describing: listoftag)
        
        let parameters:[String:Any] = ["Gender":gender,"bio":bio,"birthdate":birthdate,"Username":userName,"listoftags[]": tagsId]
        let o = NSString(string: parameters.description)
        print(o)
        if attachedImg {
            guard let mediaImage = Media(withImage: userImage, forKey: "UserImags") else { return }
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: [mediaImage], boundary: boundary)
            request.httpBody = dataBody
            
            print(dataBody as Data)
            let session = URLSession.shared
            
            session.dataTask(with: request) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print(httpResponse!)
                print("statusCode: \(code!)")
                print("**MD** response: \(response)")
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<ProfileModel>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            if let toAdd = userResponse.data {
                                self.initProfileCash(user: toAdd)
                                completion(nil,toAdd)
                            }
                        }else {
                            if let error = userResponse.message {
                                print ("Error while fetching data \(error)")
                                self.errorMsg = error
                                completion(self.errorMsg,nil)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }else {
//            guard let mediaImage = Media(withImage: UIImage(), forKey: "UserImags") else { return }
            guard let urlRequest = URL(string: url) else { return }
            var request = URLRequest(url: urlRequest)
            request.httpMethod = "POST"
            let boundary = generateBoundary()
            
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Defaults.token)", forHTTPHeaderField: "Authorization")
            let dataBody = createDataBody(withParameters: parameters, media: nil, boundary: boundary)
            request.httpBody = dataBody
            
            print(dataBody as Data)
            let session = URLSession.shared
            
            session.dataTask(with: request) { (data, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                let code  = httpResponse?.statusCode
                print(httpResponse!)
                print("statusCode: \(code!)")
                print("**MD** response: \(response)")
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        let valJsonBlock = json as! [String : Any]
                        guard let userResponse = Mapper<ProfileModel>().map(JSON: valJsonBlock) else {
                            completion(self.errorMsg, nil)
                            return
                        }
                        
                        if code == 200 || code == 201 {
                            if let toAdd = userResponse.data {
                                self.initProfileCash(user: toAdd)
                                completion(nil,toAdd)
                            }
                        }else {
                            if let error = userResponse.message {
                                print ("Error while fetching data \(error)")
                                self.errorMsg = error
                                completion(self.errorMsg,nil)
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func initProfileCash(user:ProfileObj) {
        Defaults.userName = user.userName
        Defaults.Email = user.email
        Defaults.Image = user.userImage
        Defaults.generatedusername = user.generatedusername
        Defaults.bio = user.bio
        Defaults.gender = user.gender
        Defaults.birthdate = user.birthdate
        Defaults.facebook = user.facebook
        Defaults.instagram = user.instagram
        Defaults.snapchat = user.snapchat
        Defaults.tiktok = user.tiktok
        Defaults.key = user.key
        Defaults.LocationLng = user.lang
        Defaults.LocationLat = user.lat
        Defaults.age = user.age
        Defaults.userId = user.userid
        Defaults.needUpdate = user.needUpdate
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
    
    func createDataBody(withParameters params: Parameters?, media: [Media]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\("\(value)" + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}