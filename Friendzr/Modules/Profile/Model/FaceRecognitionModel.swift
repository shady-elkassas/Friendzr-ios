//
//  FaceRecognitionModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 23/01/2022.
//

import Foundation
import ObjectMapper

class FaceRecognitionModel: Mappable {
    
    var message: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        message  <- map["result"]
    }
}
