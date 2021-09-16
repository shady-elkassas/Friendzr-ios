//
//  AllFriendesViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 15/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class AllFriendesViewModel {
    
    var friends : DynamicType<FriendsList> = DynamicType<FriendsList>()

    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllFriendes() {
        
        let url = URLs.baseURLFirst + "FrindRequest/AllFriendes?pageNumber=\(0)&pageSize=\(100)"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
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
                    self.friends.value = toAdd
                }
            }
        }
    }
}
