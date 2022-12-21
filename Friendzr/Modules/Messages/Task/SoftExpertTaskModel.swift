//
//  SoftExpertTaskModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 19/12/2022.
//

import Foundation
import ObjectMapper

typealias Recipes = [RecipesModel]

class RecipesResponse: Mappable {
    
    var q: String = ""
    var from: Int = 0
    var to: Int = 0
    var more: Bool = false
    var count: Int = 0
    var hits: [RecipesModel]? = []

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        q    <- map["q"]
        from   <- map["from"]
        to  <- map["to"]
        more    <- map["more"]
        count   <- map["count"]
        hits  <- map["hits"]
    }
}

class RecipesModel: Mappable {
    
    var recipe: RecipeObj? = nil

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        recipe    <- map["recipe"]
    }
}


class RecipeObj: Mappable {
    
    var uri: String = ""
    var label: String = ""
    var image: String = ""
    var source: String = ""
    var url: String = ""
    var shareAs: String = ""

    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        uri    <- map["uri"]
        label   <- map["label"]
        image  <- map["image"]
        source    <- map["source"]
        url   <- map["url"]
        shareAs  <- map["shareAs"]
    }
}
