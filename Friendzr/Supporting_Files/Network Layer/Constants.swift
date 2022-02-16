//
//  Constants.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

class URLs {
    static let baseURLFirst = "http://frindzr-001-site1.itempurl.com/api/"
  
    static let baseURLSecond = ""
    static let baseURLThird = ""
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
