//
//  Constants.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

class URLs {
    static let baseURLFirst = "https://localtest.friendzsocialmedia.com/api/" //local
    //        static let baseURLFirst = "https://www.friendzsocialmedia.com/api/" //product
    static let adUnitBanner = "ca-app-pub-6206027456764756/2868537426"
    static let adUnitVedio = "ca-app-pub-7917057038053337/7021771981"
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
