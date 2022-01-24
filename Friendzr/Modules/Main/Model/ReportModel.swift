//
//  ReportModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 04/01/2022.
//

import Foundation
import ObjectMapper

typealias Problems = [ProblemObj]

class ReportProblemsModel: Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    var data: [ProblemObj]? = nil
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        data    <- map["model"]
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class SendReportResponse : Mappable {
    
    var isSuccessful: Bool?
    var message: String?
    
    required init?(map: Map) {
    }
    // Mappable
    func mapping(map: Map) {
        isSuccessful   <- map["isSuccessful"]
        message  <- map["message"]
    }
}

class ProblemObj: Mappable {
    
    var id: String?
    var name: String?
    
    required init?(map: Map) {
    }
    
    init() {
    }
    
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        name   <- map["name"]
    }
}
