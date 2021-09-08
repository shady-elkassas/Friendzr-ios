//
//  EditEventViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class EditEventViewModel {
    
    // Initialise ViewModel's
    let titleEventViewModel = TitleEventViewModel()
    let descriptionViewModel = DescriptionViewModel()
    let categoryEventViewModel = CategoryEventViewModel()
    let locationEventViewModel = LocationEventViewModel()
    let totlalNumberEventViewModel = TotlalNumberEventViewModel()
    
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg : String = ""
    
    func validateEditEventCredentials() -> Bool{
        
        isSuccess =  titleEventViewModel.validateCredentials() && descriptionViewModel.validateCredentials() && categoryEventViewModel.validateCredentials() && locationEventViewModel.validateCredentials() && totlalNumberEventViewModel.validateCredentials()
        
        errorMsg = "\(titleEventViewModel.errorValue ?? "")\(descriptionViewModel.errorValue ?? "")\(categoryEventViewModel.errorValue ?? "")\(locationEventViewModel.errorValue ?? "")\(totlalNumberEventViewModel.errorValue ?? "")"
        
        return isSuccess
    }
    
    // create a method for calling api which is return a Observable
    
    //MARK:- Edit event
    func editEvent(withID eventid:String,AndTitle title:String?,AndDescription description:String?,AndStatus status: String?,AndImage image:String?,AndCategory categoryId:String?,lang:String,lat:String,totalnumbert:String?,allday:Bool?,eventdateFrom:String?,eventDateto:String?,eventfrom:String?,eventto:String?, completion: @escaping (_ error: String?, _ data: EventObj?) -> ()) {
        
        titleEventViewModel.data = title ?? ""
        descriptionViewModel.data = description ?? ""
        categoryEventViewModel.data = categoryId ?? ""
        locationEventViewModel.data = "\(lat)"
        totlalNumberEventViewModel.data = totalnumbert ?? ""
        
        if image == "" {
            self.errorMsg = "Please upload image for your event"
            completion(errorMsg, nil)
            return
        }
        
        guard validateEditEventCredentials() else {
            completion(errorMsg, nil)
            return
        }
        
        let url = URLs.baseURLFirst + "Events/updateEventData"
        let headers = RequestComponent.headerComponent([.type,.authorization])
        let bodyData = "Id=\(eventid)&Title=\(title ?? "")&description=\(description ?? "")&status=\(status ?? "")&image=\(image ?? "")&categorieId=\(categoryId ?? "")&lang=\(lang )&lat=\(lat )&totalnumbert=\(totalnumbert ?? "")&allday=\(allday ?? false)&eventdate=\(eventdateFrom ?? "")&eventdateto=\(eventDateto ?? "")&eventfrom=\(eventfrom ?? "")&eventto=\(eventto ?? "")".data(using: .utf8)
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: bodyData, andHeaders: headers) { (data,error) in
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
                if let toAdd = userResponse.data {
                    completion(nil,toAdd)
                }
            }
        }
    }
}
