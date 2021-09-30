//
//  StringExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

extension String {
    
    var localizedString: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    
    func formattedDate(with format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"
        let dateObject = dateFormatter.date(from: self)
        dateFormatter.locale = Locale(identifier: Language.currentLanguage())
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        if dateObject != nil {
            let date = dateFormatter.string(from: dateObject!)
            return date.replacedArabicDigitsWithEnglish
        } else {
            return " "
        }
    }
    
    public var replacedEnglishDigitsWithArabic: String {
        var str = self
        let map = ["0": "٠",
                   "1": "١",
                   "2": "٢",
                   "3": "٣",
                   "4": "٤",
                   "5": "٥",
                   "6": "٦",
                   "7": "٧",
                   "8": "٨",
                   "9": "٩"]
        map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
        return str
    }
    
    public var replacedArabicDigitsWithEnglish: String {
        var str = self
        let map = ["٠": "0",
                   "١": "1",
                   "٢": "2",
                   "٣": "3",
                   "٤": "4",
                   "٥": "5",
                   "٦": "6",
                   "٧": "7",
                   "٨": "8",
                   "٩": "9"]
        map.forEach { str = str.replacingOccurrences(of: $0, with: $1) }
        return str
    }
    
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
         let fontAttributes = [NSAttributedString.Key.font: font]
         let size = self.size(withAttributes: fontAttributes)
         return size.width
     }

     func heightOfString(usingFont font: UIFont) -> CGFloat {
         let fontAttributes = [NSAttributedString.Key.font: font]
         let size = self.size(withAttributes: fontAttributes)
         return size.height
     }
}

extension String {
    
    /// Longitude and latitude conversion: (degree°minute′second" format)
    ///-Parameter d: The latitude and longitude value to be converted
    func DegreeToString(d: Double) -> String {
        /// Spend
        let degree = Int(d)
        print("Spend：\(degree)°")
        /// Temporary points
        let tempMinute = Float(d - Double(degree)) * 60
        /// Minute
        let minutes = Int(tempMinute)   // Rounding
        print("Minute：\(minutes)‘")
        /// Second
        let second = Int((tempMinute - Float(minutes)) * 60)
        print("Second： \(second)\"")
        return "\(degree)°\(minutes)′\(second)″"
    }
}
