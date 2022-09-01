//
//  CommunityViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 30/08/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class CommunityViewModel {
    
    var recommendedPeople : DynamicType<RecommendedPeople> = DynamicType<RecommendedPeople>()
    var recommendedEvent : DynamicType<RecommendedEvent> = DynamicType<RecommendedEvent>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getRecommendedPeople(userId:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "FrindRequest/RecommendedPeople?userId=\(userId)"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        RequestManager().request(fromUrl: url, byMethod: "GET", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<RecommendedPeopleModel>().map(JSON: data!) else {
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
                    self.recommendedPeople.value = toAdd
                }
            }
        }
    }
    
    func getRecommendedEvent(eventId:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/RecommendedEvent?userId=\(eventId)"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        RequestManager().request(fromUrl: url, byMethod: "GET", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<RecommendedEventModel>().map(JSON: data!) else {
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
                    self.recommendedEvent.value = toAdd
                }
            }
        }
    }
}
