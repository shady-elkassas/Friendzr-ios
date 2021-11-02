//
//  EventsAroundMeViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class EventsAroundMeViewModel {
    
    var locations : DynamicType<EventsAroundList> = DynamicType<EventsAroundList>()
    var events : DynamicType<EventsInLocations> = DynamicType<EventsInLocations>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllEventsAroundMe() {
        
        let url = URLs.baseURLFirst + "Events/Eventsaroundme"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventsAroundMeModel>().map(JSON: data!) else {
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
                    self.locations.value = toAdd
                }
            }
        }
    }
    
    func getEventsByLoction(lat:Double,lng:Double) {
        
        let url = URLs.baseURLFirst + "Events/locationEvente"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let params:[String:Any] = ["lat":lat,"lang":lng]
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: params, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventsListByLocationModel>().map(JSON: data!) else {
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
                    self.events.value = toAdd
                }
            }
        }
    }
}
