//
//  AllFriendesViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class AllFriendesViewModel {
    
    var friends : DynamicType<ConversationList> = DynamicType<ConversationList>()
    var friendsTemp : ConversationList = ConversationsDataModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllFriendes(pageNumber:Int,search:String) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "FrindRequest/AllFriendes"
        let headers = RequestComponent.headerComponent([.authorization,.type,.lang])
        
        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":10,"search":search]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ConversationsResponse>().map(JSON: data!) else {
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
                            if !(self.friendsTemp.data?.contains(where: { $0.userId == itm.userId }) ?? false) {
                                self.friendsTemp.data?.append(itm)
                            }
                        }
                        self.friends.value = self.friendsTemp
                    } else {
                        self.friends.value = toAdd
                        self.friendsTemp = toAdd
                    }
                }
            }
        }
    }
}
