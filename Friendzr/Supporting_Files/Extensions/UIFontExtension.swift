//
//  UIFontExtension.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

class Font: NSObject {
    
    static let AppFontName = "Montserrat" //app font here
    
    enum FontStyle {
        case medium
        case regulaer
        case bold
        case semiBold
        case light
        case black
    }
    
}

extension Font.FontStyle {
    var style: String {
        var fontStyle = ""
        
        switch self {
            
        case .medium:
            fontStyle = "Medium"
        case .regulaer:
            fontStyle = "Regular"
        case .bold:
            fontStyle = "Bold"
        case .semiBold:
            fontStyle = "SemiBold"
        case .light:
            fontStyle = "Light"
        case .black:
            fontStyle = "Black"
        }
        
        return Font.AppFontName + "-" + fontStyle
    }
}

extension UIFont {
    
    func setFont(withName name: Font.FontStyle, size: CGFloat? = 15) -> UIFont {
        
        if let font = UIFont(name: name.style, size: 15) {
            return font
        }
        
        return UIFont.systemFont(ofSize: size ?? 15)
    }
}
