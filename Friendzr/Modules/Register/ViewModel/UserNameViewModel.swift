//
//  UserNameViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation


class UserNameViewModel : ValidationViewModel {
    var errorValue: String?
    var errorMessage: String = "Please enter a valid user name should not be less than 3 character or more than 32 characters".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        if Defaults.userName_MinLength != 0 {
            guard validateLength(text: data, size: (Defaults.userName_MinLength,Defaults.userName_MaxLength)) else {
                errorValue = "Please enter a valid user name should not be less than \(Defaults.userName_MinLength) character or more than \(Defaults.userName_MaxLength) characters"
                return false
            }

        }else {
            guard validateLength(text: data, size: (3,32)) else {
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
