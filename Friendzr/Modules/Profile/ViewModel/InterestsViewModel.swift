//
//  InterestsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class InterestsViewModel {
    
    var interests : DynamicType<InterestsList> = DynamicType<InterestsList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllInterests(completion: @escaping (_ error: String?, _ data: [InterestObj]?) -> ())  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/GetAllInterests"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let interestResponse = Mapper<InterestsModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = interestResponse.data {
                    print("toAdd ::: \(toAdd)")
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func getAllInterests()  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/GetAllInterests"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let interestResponse = Mapper<InterestsModel>().map(JSON: data!) else {
                self.error.value = error!
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = interestResponse.data {
                    print("toAdd ::: \(toAdd)")
                    self.interests.value = toAdd
                }
            }
        }
    }
    
    func addMyNewInterest(name:String,completion: @escaping (_ error: String?, _ data: NewTagAddedObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/userTag"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let interestResponse = Mapper<AddUserInterestModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = interestResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func deleteInterest(ById id:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/DeleteInterest"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["interestID": id]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let interestResponse = Mapper<AddUserInterestModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = interestResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func EditInterest(ByID id:String,name:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/updateInterest"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name,"entityId":id]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let interestResponse = Mapper<AddUserInterestModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = interestResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
