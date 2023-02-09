//
//  ExtensionDate.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 13/10/2021.
//

import Foundation
import UIKit

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    
    func computeNewDate(from fromDate: Date, to toDate: Date) -> Date {
        let delta = toDate - fromDate // `Date` - `Date` = `TimeInterval`
        let today = Date()
        if delta < 0 {
            return today
        } else {
            return today + delta // `Date` + `TimeInterval` = `Date`
        }
    }
}

extension String {

    func toDate(withFormat format: String = "dd-MM-yyyy HH:mm:ss")-> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "dd-MM-yyyy'T'HH:mm:ssZ"
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }    
}

extension Date {    
    func toString(withFormat format: String = "EEEE ، d MMMM yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.dateStyle = .full
        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }
}

