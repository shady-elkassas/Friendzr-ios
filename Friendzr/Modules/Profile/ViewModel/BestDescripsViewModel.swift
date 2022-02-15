//
//  BestDescripsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/02/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class BestDescripsViewModel {
    
    var bestDescrips : DynamicType<BestDescripsList> = DynamicType<BestDescripsList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllBestDescrips(completion: @escaping (_ error: String?, _ data: [BestDescripsObj]?) -> ())  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/GetAllWhatBestDescripsMe"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<BestDescripsModel>().map(JSON: data!) else {
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
    
    func getAllBestDescrips()  {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/GetAllWhatBestDescripsMe"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<BestDescripsModel>().map(JSON: data!) else {
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
                    self.bestDescrips.value = toAdd
                }
            }
        }
    }
    
    func addMyNewBestDescrip(name:String,completion: @escaping (_ error: String?, _ data: NewBestDescripsAddedObj?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/ADDWhatBestDescripsMe"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in

            guard let userResponse = Mapper<AddUserBestDescripsModel>().map(JSON: data!) else {
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
    
    func deleteBestDescrips(ById id:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/DeleteInterest"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["interestID": id]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in

            guard let userResponse = Mapper<AddUserBestDescripsModel>().map(JSON: data!) else {
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
    
    func EditBestDescrip(ByID id:String,name:String,completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Interests/updateInterest"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["name": name,"entityId":id]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in

            guard let userResponse = Mapper<AddUserBestDescripsModel>().map(JSON: data!) else {
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
