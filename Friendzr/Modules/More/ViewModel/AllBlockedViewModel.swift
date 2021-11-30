//
//  AllBlockedViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class AllBlockedViewModel {
    
    var blocklist : DynamicType<FriendsList> = DynamicType<FriendsList>()
    
    var blocklistTemp : FriendsList = AllFriendesDataModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllBlockedList(pageNumber:Int) {
        
        let url = URLs.baseURLFirst + "FrindRequest/AllBlocked"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let parameters:[String : Any] = ["pageNumber": pageNumber,"pageSize":10]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AllFriendesModel>().map(JSON: data!) else {
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
                            if !(self.blocklistTemp.data?.contains(where: { $0.userId == itm.userId }) ?? false) {
                                self.blocklistTemp.data?.append(itm)
                            }
                        }
                        self.blocklist.value = self.blocklistTemp
                    } else {
                        self.blocklist.value = toAdd
                        self.blocklistTemp = toAdd
                    }
                }
            }
        }
    }
}
