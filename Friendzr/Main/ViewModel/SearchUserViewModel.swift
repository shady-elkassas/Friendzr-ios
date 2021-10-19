//
//  SearchUserViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/19/21.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class SearchUserViewModel {
    
    // Initialise ViewModel's
    
    var usersinChat : DynamicType<ChatList> = DynamicType<ChatList>()
    //    var chatsTemp : ChatList = ChatListDataModel()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    // create a method for calling api which is return a Observable
    //MARK:- Chat list
    func SearshUsersinChat(ByUserName username:String) {
        
        let url = URLs.baseURLFirst + "Messages/SearshUsersinChat"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        let parameters:[String : Any] = ["username":username]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: parameters, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<ChatsListModel>().map(JSON: data!) else {
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
                    self.usersinChat.value = toAdd
                }
            }
        }
    }
}
