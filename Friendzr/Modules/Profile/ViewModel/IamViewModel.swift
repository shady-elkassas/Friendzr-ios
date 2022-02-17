//
//  IamViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/02/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class IamViewModel {
    
    var IAM : DynamicType<IamList> = DynamicType<IamList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllIam(completion: @escaping (_ error: String?, _ data: [IamObj]?) -> ())  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/GETIam"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<IamModel>().map(JSON: data!) else {
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
                if let toAdd = userResponse.data {
                    print("toAdd ::: \(toAdd)")
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func getAllIam()  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/GETIam"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<IamModel>().map(JSON: data!) else {
                self.error.value = error!
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    print("toAdd ::: \(toAdd)")
                    self.IAM.value = toAdd
                }
            }
        }
    }
    
    func addMyNewIam(name:String,completion: @escaping (_ error: String?, _ data: NewIamAddedObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/ADDIam"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AddUserIamModel>().map(JSON: data!) else {
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
                if let toAdd = userResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func deleteIam(ById id:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/DeleteIam"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["interestID": id]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AddUserIamModel>().map(JSON: data!) else {
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
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
    
    func EditIam(ByID id:String,name:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/updateIam"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name,"entityId":id]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AddUserIamModel>().map(JSON: data!) else {
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
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
