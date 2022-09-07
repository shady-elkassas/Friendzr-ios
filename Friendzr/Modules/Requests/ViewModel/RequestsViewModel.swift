//
//  RequestsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class RequestsViewModel {
    
    var requests : DynamicType<UsersList> = DynamicType<UsersList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    var requestsTemp : UsersList = FeedDataModel()

    //Get All Requests
    func getAllRequests(requestesType:Int,pageNumber:Int) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "FrindRequest/Allrequest"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["requestesType":requestesType,"pageNumber": pageNumber,"pageSize":20,"search":""]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<FeedModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.requestsTemp.data?.removeAll()
                    if pageNumber > 0 {
                        for itm in toAdd.data ?? [] {
                            if !(self.requestsTemp.data?.contains(where: { $0.userId == itm.userId }) ?? false) {
                                self.requestsTemp.data?.append(itm)
                            }
                        }
                        
                        self.requests.value = self.requestsTemp
                    } else {
                        self.requests.value = toAdd
                        self.requestsTemp = toAdd
                    }
                }
            }
        }
    }
}
