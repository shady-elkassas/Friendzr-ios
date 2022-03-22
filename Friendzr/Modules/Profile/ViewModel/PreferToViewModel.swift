//
//  PreferToViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/02/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class PreferToViewModel {
    
    var PreferTo : DynamicType<PreferToList> = DynamicType<PreferToList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllPreferTo(completion: @escaping (_ error: String?, _ data: [PreferToObj]?) -> ())  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "prefertoLISTES/GETpreferto"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<PreferToModel>().map(JSON: data!) else {
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
    
    func getAllPreferTo()  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "prefertoLISTES/GETpreferto"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<PreferToModel>().map(JSON: data!) else {
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
                    self.PreferTo.value = toAdd
                }
            }
        }
    }
    
    func addMyNewPreferTo(name:String,completion: @escaping (_ error: String?, _ data: NewPreferToAddedObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "prefertoLISTES/ADDpreferto"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AddUserPreferToModel>().map(JSON: data!) else {
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
    
    func deletePreferTo(ById id:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "prefertoLISTES/Deletepreferto"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["interestID": id]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AddUserPreferToModel>().map(JSON: data!) else {
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
    
    func EditPreferTo(ByID id:String,name:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "prefertoLISTES/updatepreferto"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["name": name,"entityId":id]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AddUserPreferToModel>().map(JSON: data!) else {
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
