//
//  AttendeesViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 07/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class AttendeesViewModel {
    
    var attendees : DynamicType<AttendeesList> = DynamicType<AttendeesList>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var error:DynamicType<String> = DynamicType()

    // create a method for calling api which is return a Observable
    
    //MARK:- Add event
    func editAttendees(ByUserAttendId userAttendId:String,AndEventid eventid:String,AndStutus stutus:Int, completion: @escaping (_ error: String?, _ data: String?) -> ()) {
        
        let url = URLs.baseURLFirst + "Events/Clickoutevent"
        let headers = RequestComponent.headerComponent([.type,.authorization])
//        let bodyData = "UserattendId=\(userAttendId)&EventDataid=\(eventid)&stutus=\(stutus)".data(using: .utf8)
        let parameters:[String : Any] = ["UserattendId": userAttendId,"EventDataid":eventid,"stutus":stutus]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            guard let userResponse = Mapper<EventModel>().map(JSON: data!) else {
                self.error.value = error!
                completion(self.error.value, nil)
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
                completion(self.error.value, nil)
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.message {
                    completion(nil,toAdd)
                }
            }
        }
    }

    func getEventAttendees(ByEventID eventid:String) {
        
        let url = URLs.baseURLFirst + "Events/getEventAttende"
        let headers = RequestComponent.headerComponent([.authorization,.type])
//        let bodyData = "id=\(eventid)".data(using: .utf8)
        let parameters:[String : Any] = ["id": eventid]

        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AttendeesModel>().map(JSON: data!) else {
                self.error.value = error!
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.attendees.value = toAdd
                }
            }
        }
    }
}
