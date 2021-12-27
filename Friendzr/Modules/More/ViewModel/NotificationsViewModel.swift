//
//  NotificationsViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/10/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class NotificationsViewModel {
    
    var notifications : DynamicType<Notifications> = DynamicType<Notifications>()
    
    var notificationsTemp : Notifications = NotificationsModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getNotifications(pageNumber:Int) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Messages/NotificationData"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":10]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<NotificationsResponse>().map(JSON: data!) else {
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
                    if pageNumber > 0 {
                        for itm in toAdd.data ?? [] {
                            if !(self.notificationsTemp.data?.contains(where: { $0.id == itm.id }) ?? false) {
                                self.notificationsTemp.data?.append(itm)
                            }
                        }
                        self.notifications.value = self.notificationsTemp
                    } else {
                        self.notifications.value = toAdd
                        self.notificationsTemp = toAdd
                    }
                }
            }
        }
    }
}
