//
//  EventsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 31/08/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class EventsViewModel {
    
    var events : DynamicType<EventsList> = DynamicType<EventsList>()
    var event : DynamicType<Event> = DynamicType<Event>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllEvents() {
        
        let url = URLs.baseURLFirst + "Events/getallEvent"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventsListModel>().map(JSON: data!) else {
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
    
    func getEventByID(id:String) {
        let url = URLs.baseURLFirst + "Events/getEvent"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["id": id]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventModel>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.event.value = toAdd
                }
            }
        }
    }
}
