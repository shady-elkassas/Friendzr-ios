//
//  DeepLinks.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 20/01/2022.
//

import Foundation
import UIKit

enum DeepLink: String { 
    case Main
    case Login
    case Register
    case Splach
    case Profile
    case More
    case Feed
    case Map
    case Events
    case FaceRecognition
}


extension DeepLink: Name {
    var name: String {
        return self.rawValue
    }
}


/*
 This is where we can capture all the responder chain events for our app.
 */

@objc protocol FriendzrResponder {
    @objc optional func didTap(sender: UIButton?)
}
