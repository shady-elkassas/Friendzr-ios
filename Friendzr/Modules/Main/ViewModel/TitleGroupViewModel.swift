//
//  TitleGroupViewModel.swift
//  Friendzr
//
//  Created by Shady Elkassas on 17/01/2022.
//

import Foundation
class NameGroupViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please enter a valid name for your group".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (1,40)) else {
            errorValue = errorMessage
            return false
        }
        
        errorValue = ""
        return true
    }
    
    func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
}
