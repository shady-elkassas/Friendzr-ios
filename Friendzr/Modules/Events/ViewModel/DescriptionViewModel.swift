//
//  DescriptionViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import Foundation

class DescriptionViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please enter a valid description for your event".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (Defaults.eventDetailsDescription_MinLength,Defaults.eventDetailsDescription_MaxLength)) else {
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
