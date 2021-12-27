//
//  AllCategoriesViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 06/09/2021.
//

import Foundation
import ObjectMapper
import MobileCoreServices
//import Alamofire

class AllCategoriesViewModel {
    
    var cats : DynamicType<CategoriesList> = DynamicType<CategoriesList>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    func getAllCategories() {
        CancelRequest.currentTask = false
        let url = URLs.baseURLFirst + "Events/GetAllcategory"
        let headers = RequestComponent.headerComponent([.authorization,.type])
        
        RequestManager().request(fromUrl: url, byMethod: "POST", withParameters: nil, andHeaders: headers) { (data,error) in
            
            guard let userResponse = Mapper<CategoriesModel>().map(JSON: data!) else {
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
                    self.cats.value = toAdd
                }
            }
        }
    }
}
