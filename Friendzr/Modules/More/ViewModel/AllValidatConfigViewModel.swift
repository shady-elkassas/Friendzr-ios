//
//  AllValidatConfigViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 15/03/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices
import Alamofire

class AllValidatConfigViewModel {
    
    var userValidationConfig : DynamicType<AllValidatConfigObj> = DynamicType<AllValidatConfigObj>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var isLoading : Bool = false
    var errorMsg :DynamicType<String> = DynamicType()
    
    func getAllValidatConfig() {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Account/GetAllValidatConfig"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<AllValidatConfigModel>().map(JSON: data!) else {
                self.errorMsg.value = error ?? ""
                return
            }
            
            if let error = error {
                print ("Error while fetching data \(error)")
                self.errorMsg.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.data {
                    self.userValidationConfig.value = toAdd
                }
            }
        }
    }
    
}
