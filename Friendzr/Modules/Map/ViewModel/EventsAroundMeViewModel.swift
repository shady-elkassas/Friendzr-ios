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
    //    var events : DynamicType<EventsInLocations> = DynamicType<EventsInLocations>()
    var eventsOnlyMe : DynamicType<EventsOnlyAroundList> = DynamicType<EventsOnlyAroundList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllEventsAroundMe() {
        CancelRequest.currentTask = false
        var url = URLs.baseURLFirst + "Public/EventsAroundMe"
        if Defaults.token != "" {
            url = URLs.baseURLFirst + "Events/Eventsaroundme"
        }
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let params:[String:Any] = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: params, andHeaders: headers) { (data,error) in
            
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
    
    
    func getAllEventsOnlyAroundMe(pageNumber:Int) {
        CancelRequest.currentTask = false
        
        var url = URLs.baseURLFirst + "Public/OnlyEventsAround"
        
        if Defaults.token != "" {
            url = URLs.baseURLFirst + "Events/OnlyEventsAround"
        }
        
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let params:[String:Any] = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":100,"PageNumber":pageNumber]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: params, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<EventsOnlyAroundMeResponse>().map(JSON: data!) else {
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
                    self.eventsOnlyMe.value = toAdd
                }
            }
        }
    }
    
    //    func getEventsByLoction(lat:Double,lng:Double) {
    //        CancelRequest.currentTask = false
    //        let url = URLs.baseURLFirst + "Events/locationEvente"
    //        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
    //        let params:[String:Any] = ["lat":lat,"lang":lng]
    //        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: params, andHeaders: headers) { (data,error) in
    //
    //            guard let userResponse = Mapper<EventsListByLocationModel>().map(JSON: data!) else {
    //                self.error.value = error
    //                return
    //            }
    //            if let error = error {
    //                print ("Error while fetching data \(error)")
    //                self.error.value = error
    //            }
    //            else {
    //                // When set the listener (if any) will be notified
    //                if let toAdd = userResponse.data {
    //                    self.events.value = toAdd
    //                }
    //            }
    //        }
    //    }
}
