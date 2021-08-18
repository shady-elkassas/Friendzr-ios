//
//  Language.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation

class Language {
    
    class func currentLanguage() -> String {
        
        let def = UserDefaults.standard
        
        let language = def.object(forKey: "AppleLanguages") as! NSArray
        let firstLang = language.firstObject as! String
        if firstLang == "ar" {
            return firstLang
        } else {
            return "en"
        }
    }
    
    class func setAppLanuage(lang: String) {
        
        let def = UserDefaults.standard
        
        def.set([lang, currentLanguage()], forKey: "AppleLanguages")
        def.synchronize()
    }
    
    class func Localized(text: String) -> String{
        let Text = NSLocalizedString(text, comment: "")
        return Text
    }
    class func getCurrentLanguageForTheApp () -> lang {
        return .Ar
    }
}

enum lang : String {
    case Ar
    case En
}
