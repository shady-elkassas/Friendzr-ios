//
//  BioViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import Foundation

class BioViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please enter a valid bio with more than 10 characters and no more than 100 characters".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        if Defaults.userBio_MinLength != 0 {
            guard validateLength(text: data, size: (Defaults.userBio_MinLength,Defaults.userBio_MaxLength)) else {
                errorValue = "Please enter a valid bio with more than \(Defaults.userBio_MinLength) characters and no more than \(Defaults.userBio_MaxLength) characters"
                return false
            }
        }else {
            guard validateLength(text: data, size: (10,100)) else {
                errorValue = errorMessage
                return false
            }
        }

        
        errorValue = ""
        return true
    }
    
    func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
}

class LookingForViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please enter what are you looking for with more than 10 characters and no more than 150 characters".localizedString
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
