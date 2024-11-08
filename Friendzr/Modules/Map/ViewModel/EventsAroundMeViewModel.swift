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
    var eventsOnlyMe : DynamicType<EventsOnlyAroundList> = DynamicType<EventsOnlyAroundList>()
    var eventsOnlyMeTemp : EventsOnlyAroundList = EventsOnlyAroundMeModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllEventsAroundMe(ByCatIds catIDs: [String],dateCriteria:String,startDate:String,endDate:String) {
        CancelRequest.currentTask = false
        var url = URLs.baseURLFirst + "Public/EventsAroundMe"
        
        if Defaults.token != "" {
            url = URLs.baseURLFirst + "Events/EventsDataAroundUser"
        }
        
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        var params:[String:Any] = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng]
        
        if catIDs.count != 0 {
            if dateCriteria != "" {
                if dateCriteria != "Custom" {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"categories": catIDs,"dateCriteria":dateCriteria]
                }else {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"categories": catIDs,"dateCriteria":dateCriteria,"startDate":startDate,"endDate":endDate]
                }
            }else {
                params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"categories": catIDs]
            }
        }
        else {
            if dateCriteria != "" {
                if dateCriteria != "Custom" {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"dateCriteria":dateCriteria]
                }else {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"dateCriteria":dateCriteria,"startDate":startDate,"endDate":endDate]
                }
            }
        }
        
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
    
    
    func getAllEventsOnlyAroundMe(ByCatIds catIDs: [String],pageNumber:Int,dateCriteria:String,startDate:String,endDate:String) {
        CancelRequest.currentTask = false
        
        var url = URLs.baseURLFirst + "Public/OnlyEventsAround"
        
        if Defaults.token != "" {
            url = URLs.baseURLFirst + "Events/OnlyEventsAroundUser"
        }
        
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        var params:[String:Any] = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":20,"PageNumber":pageNumber]
        
        if catIDs.count != 0 {
            if dateCriteria != "" {
                if dateCriteria != "Custom" {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":20,"PageNumber":pageNumber,"categories": catIDs,"dateCriteria":dateCriteria]
                }else {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":20,"PageNumber":pageNumber,"categories": catIDs,"dateCriteria":dateCriteria,"startDate":startDate,"endDate":endDate]
                }
            }else {
                params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":20,"PageNumber":pageNumber,"categories": catIDs]
            }
        }
        else {
            if dateCriteria != "" {
                if dateCriteria != "Custom" {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":20,"PageNumber":pageNumber,"dateCriteria":dateCriteria]
                }else {
                    params = ["lat":Defaults.LocationLat,"lang":Defaults.LocationLng,"PageSize":20,"PageNumber":pageNumber,"dateCriteria":dateCriteria,"startDate":startDate,"endDate":endDate]
                }
            }
        }
        
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
                    if pageNumber > 1 {
                        for itm in toAdd.data ?? [] {
                            if !(self.eventsOnlyMeTemp.data?.contains(where: { $0.id == itm.id }) ?? false) {
                                self.eventsOnlyMeTemp.data?.append(itm)
                            }
                        }
                        self.eventsOnlyMe.value = self.eventsOnlyMeTemp
                    } else {
                        self.eventsOnlyMe.value = toAdd
                        self.eventsOnlyMeTemp = toAdd
                    }
                }
            }
        }
    }
    
    func getEventsByLoction(lat:Double,lng:Double,CatIds catIDs: [String],dateCriteria:String,startDate:String,endDate:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/EventsByLocation"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        var params:[String:Any] = ["lat":lat,"lang":lng]
        
        if catIDs.count != 0 {
            if dateCriteria != "" {
                if dateCriteria != "Custom" {
                    params = ["lat":lat,"lang":lng,"categories": catIDs,"dateCriteria":dateCriteria]
                }else {
                    params = ["lat":lat,"lang":lng,"categories": catIDs,"dateCriteria":dateCriteria,"startDate":startDate,"endDate":endDate]
                }
            }else {
                params = ["lat":lat,"lang":lng,"categories": catIDs]
            }
        }
        else {
            if dateCriteria != "" {
                if dateCriteria != "Custom" {
                    params = ["lat":lat,"lang":lng,"dateCriteria":dateCriteria]
                }else {
                    params = ["lat":lat,"lang":lng,"dateCriteria":dateCriteria,"startDate":startDate,"endDate":endDate]
                }
            }
        }

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
