//
//  GenderbylocationViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/10/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class GenderbylocationViewModel {
    
    var gender : DynamicType<PeopleAroundMeObj> = DynamicType<PeopleAroundMeObj>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getGenderbylocation(ByLat lat:Double,AndLng lng:Double) {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/Genderbylocation"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        let params:[String:Any] = ["lat":lat,"lang":lng]
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: params, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<GenderbylocationModel>().map(JSON: data!) else {
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
                    self.gender.value = toAdd
                }
            }
        }
    }
}
