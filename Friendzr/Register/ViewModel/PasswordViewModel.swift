//
//  PasswordViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

class PasswordViewModel : ValidationViewModel {
     
    var errorMessage: String = "Please enter a valid Password".localizedString
    var confirmErrorMessage: String = "Please check Passwords are not equal".localizedString
    
    var data: String = ""
    var errorValue: String? = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (8,30)) else {
            errorValue = errorMessage
            return false;
        }
        
        errorValue = ""
        return true
    }
    func validateConfirmation(fstPass:String) -> Bool {
        guard validateConfirm(text: data, oldPassword: fstPass) else {
            errorValue = confirmErrorMessage
            return false
        }
        errorValue = ""
        return true
    }
    func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
    func validateConfirm(text : String, oldPassword : String) -> Bool{
        return text == oldPassword
    }
}

class ConfirmPasswordViewModel : ValidationViewModel {
     
    var errorMessage: String = "Please enter a valid Confirmation Password".localizedString
    var confirmErrorMessage: String = "Please check Passwords are not equal".localizedString
    
    var data: String = ""
    var errorValue: String? = ""
    
    func validateCredentials() -> Bool {
        
        guard validateLength(text: data, size: (8,30)) else {
            errorValue = errorMessage
            return false;
        }
        
        errorValue = ""
        return true
    }
    
    func validateConfirmation(fstPass:String) -> Bool {
        guard validateConfirm(text: data, oldPassword: fstPass) else {
            errorValue = confirmErrorMessage
            return false
        }
        errorValue = ""
        return true
    }
    func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
    func validateConfirm(text : String, oldPassword : String) -> Bool{
        return text == oldPassword
    }
}
