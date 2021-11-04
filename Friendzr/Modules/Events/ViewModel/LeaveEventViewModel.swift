//
//  LeaveEventViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 08/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class LeaveEventViewModel {
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    // create a method for calling api which is return a Observable
    
    //MARK:- leave Event
    func leaveEvent(ByEventid eventid:String, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        let url = URLs.baseURLFirst + "Events/leaveEvent"
        let headers = RequestComponent.headerComponent([.type,.authorization])
//        let bodyData = "EventDataid=\(eventid)".data(using: .utf8)
        let parameters:[String : Any] = ["EventDataid": eventid]

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
