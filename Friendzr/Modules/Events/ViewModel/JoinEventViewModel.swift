//
//  JoinEventViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class JoinEventViewModel {
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Add event
    func joinEvent(ByEventid eventid:String,JoinDate:String,Jointime:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/joinEvent"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let parameters:[String : Any] = ["EventDataid": eventid,"JoinDate":JoinDate,"Jointime":Jointime]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<EventModel>().map(JSON: data!) else {
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
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
