//
//  UserImageViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/09/2021.
//

import Foundation

class UserImageViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please upload user image".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (2,40)) else {
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
