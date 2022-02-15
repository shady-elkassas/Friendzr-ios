//
//  RequestComponent.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation
import Alamofire

class RequestComponent {
    
    enum Component {
        case lang
        case authorization
        case type
    }
    
    class func headerComponent(_ component: [Component]) -> HTTPHeaders {
        var header = HTTPHeaders()
        
        for singleComponent in component{
            switch singleComponent{
            case .lang:
                header["lang"] = "en"
            case .authorization:
                let tkn = "Bearer \(Defaults.token)"
                header["Authorization"] = tkn
            case .type:
                header["Content-Type"] = "application/x-www-form-urlencoded"
            }
        }
        
        return header
    }
}
