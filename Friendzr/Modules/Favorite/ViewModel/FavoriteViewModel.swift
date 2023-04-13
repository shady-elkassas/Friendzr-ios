//
//  FavoriteViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/03/2023.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class FavoriteViewModel {
    
    var events : DynamicType<EventsList> = DynamicType<EventsList>()
    var event : DynamicType<Event> = DynamicType<Event>()
    
    var eventsTemp : EventsList = EventsDataModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getMyFavoritesEvents(pageNumber:Int) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/FavoriteEvents"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])

        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":10]
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
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
                    if pageNumber > 1 {
                        for itm in toAdd.data ?? [] {
                            if !(self.eventsTemp.data?.contains(where: { $0.id == itm.id }) ?? false) {
                                self.eventsTemp.data?.append(itm)
                            }
                        }
                        self.events.value = self.eventsTemp
                    } else {
                        self.events.value = toAdd
                        self.eventsTemp = toAdd
                    }
                }
            }
        }
    }
    
//    func toggleFavorite(eventId:String ,isFavorite:Bool) {
//        CancelRequest.currentTask = false
//        let url = URLs.baseURLFirst + "Events/FavoriteEvent"
//        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
//        let parameters:[String : Any] = ["eventId": eventId,"isFavorite":isFavorite]
//
//        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
//
//            guard let userResponse = Mapper<EventModel>().map(JSON: data!) else {
//                self.error.value = error
//                return
//            }
//            if let error = error {
//                self.error.value = error
//            }
//            else {
//                // When set the listener (if any) will be notified
//                if let toAdd = userResponse.data {
//                    self.event.value = toAdd
//                }
//            }
//        }
//    }
    
    func toggleFavorite(ByEventID eventId:String, isFavorite: Bool,completion: @escaping (_ error: String?, _ data: Bool?) -> ()) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/FavoriteEvent"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        let parameters:[String : Any] = ["eventId": eventId,"isFavorite":isFavorite]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ToggleFavoriteEventModel>().map(JSON: data!) else {
                self.error.value = error
                completion(self.error.value, nil)
                return
            }
            if let error = error {
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
}
