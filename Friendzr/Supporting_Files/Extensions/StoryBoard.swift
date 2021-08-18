//
//  StoryBoard.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation

enum StoryBoard: String {
    case Main
    case Login
    case Register
    case Splach
    case Profile
    case More
    case Feed
    case Map
    case Events
}

extension StoryBoard: Name {
    var name: String {
        return self.rawValue
    }
}

protocol Name {
    var name: String { get }
}
