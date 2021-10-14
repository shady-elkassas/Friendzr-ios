//
//  BioViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import Foundation

class BioViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please enter a valid bio more than 10 letters".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (10,150)) else {
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
