//
//  Localizer.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

class Localizer {
    
    class func DoExchange() {
        
        //Handle to change language with out reopen app
        ExchangeMethodForClass(className: Bundle.self, orighinalSelector: #selector(Bundle.localizedString(forKey:value:table:)),
                               overrideSelector: #selector(Bundle.customLocaliedStringForKey(key:value:table:)))
        
        // Change Directions
        ExchangeMethodForClass(className: UIApplication.self, orighinalSelector: #selector(getter: UIApplication.userInterfaceLayoutDirection), overrideSelector: #selector(getter: UIApplication.customUserInterfaceLayoutDirection))
    }
}


extension Bundle {
    
    @objc func customLocaliedStringForKey(key: String, value: String, table tableName: String) -> String {
        
        let currentLanguage = Language.currentLanguage()
        var bundle = Bundle()
        
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            bundle = Bundle(path: path)!
        }else{
            let path = Bundle.main.path(forResource: "Base", ofType: "lproj")
            bundle = Bundle(path: path!)!
        }
        return bundle.customLocaliedStringForKey(key: key , value: value ,table: tableName)
    }
}

extension UIApplication {
    
    @objc var customUserInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        get {
            var direction = UIUserInterfaceLayoutDirection.leftToRight
            
            if Language.currentLanguage() == "ar" {
                direction = .leftToRight
            }
            return direction
        }
    }
}


func ExchangeMethodForClass(className: AnyClass, orighinalSelector: Selector, overrideSelector: Selector){
    
    let originalMethod: Method = class_getInstanceMethod(className, orighinalSelector)!
    let overrideMethod: Method = class_getInstanceMethod(className, overrideSelector)!
    
    if class_addMethod(className, orighinalSelector,
                       method_getImplementation(overrideMethod),
                       method_getTypeEncoding(overrideMethod)) {
        
        class_replaceMethod(className, overrideSelector,
                            method_getImplementation(overrideMethod),
                            method_getTypeEncoding(originalMethod))
    }else{
        
        method_exchangeImplementations(originalMethod, overrideMethod)
    }
}

