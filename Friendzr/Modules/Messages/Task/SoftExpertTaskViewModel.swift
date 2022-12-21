//
//  SoftExpertTaskViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 19/12/2022.
//

import Foundation
import ObjectMapper
import MobileCoreServices

class SoftExpertTaskViewModel {
    
    var recipes : DynamicType<Recipes> = DynamicType<Recipes>()
    
    // Fields that bind to our view's
    var isSuccess : Bool = false
    var error:DynamicType<String> = DynamicType()
    
    var recipesTemp : Recipes = [RecipesModel]()
    
    //MARK:- Get All Users Request
    func getRecipes(fromPage:Int,toPage:Int,healthName:String,searchText:String) {
        
        let url = "https://api.edamam.com/search?q=\(searchText)&app_id=0ff762b4&app_key=54cfc422fdfd8cfc0de6f7750b2a8d06&health=\(healthName)&from=\(fromPage)&to=\(toPage)"
        
        RequestManager().request(fromUrl: url, byMethod: "GET", withParameters: nil, andHeaders: nil) { (data,error) in
            guard let userResponse = Mapper<RecipesResponse>().map(JSON: data!) else {
                self.error.value = error
                return
            }
            if let error = error {
                print ("Error while fetching data \(error)")
                self.error.value = error
            }
            else {
                // When set the listener (if any) will be notified
                if let toAdd = userResponse.hits {
                    self.recipes.value = toAdd
                }
            }
        }
    }
}
