//
//  EventTypeViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 22/03/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class EventTypeViewModel {
    
    var types : DynamicType<EventTypeList> = DynamicType<EventTypeList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllEventType() {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/geteventtype"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventTypeModel>().map(JSON: data!) else {
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
                    self.types.value = toAdd
                }
            }
        }
    }
}
