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

public struct DynamicType<T> {
    typealias ModelEventListener = (T)->Void
    typealias Listeners = [ModelEventListener]
    
    private var listeners:Listeners = []
    var value:T? {
        didSet {
            for (_,observer) in listeners.enumerated() {
                if let value = value {
                    observer(value)
                }
            }
        }
    }
    
    mutating func bind(_ listener:@escaping ModelEventListener) {
        listeners.removeAll()
        listeners.append(listener)
        if let value = value {
            listener(value)
        }
    }
}
