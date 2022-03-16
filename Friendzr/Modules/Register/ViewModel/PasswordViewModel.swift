//
//  PasswordViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

class PasswordViewModel : ValidationViewModel {
     
    var errorMessage: String = "Please enter a valid password should not be less than 8 characters or more than 100 characters and password should be a combination of letters and numbers, it should have at least one letter and at least one number".localizedString
    var confirmErrorMessage: String = "Please check Passwords are not equal".localizedString
    
    var data: String = ""
    var errorValue: String? = ""
    
    func validateCredentials() -> Bool {
        
        if Defaults.password_MinLength != 0 {
            guard validateLength(text: data, size: (Defaults.password_MinLength,Defaults.password_MaxLength)) else {
                errorValue = "Please enter a valid password should not be less than \(Defaults.password_MinLength) characters or more than \(Defaults.password_MaxLength) characters and password should be a combination of letters and numbers, it should have at least one letter and at least one number".localizedString
                return false;
            }
        }else {
            guard validateLength(text: data, size: (8,100)) else {
                errorValue = errorMessage
                return false;
            }
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
     
    var errorMessage: String = "Please enter a valid confirmation password should not be less than 8 characters or more than 100 characters and confirmation password should be a combination of letters and numbers, it should have at least one letter and at least one number".localizedString
    var confirmErrorMessage: String = "Please check Passwords are not equal".localizedString
    
    var data: String = ""
    var errorValue: String? = ""
    
    func validateCredentials() -> Bool {
        
        if Defaults.password_MinLength != 0 {
            guard validateLength(text: data, size: (Defaults.password_MinLength,Defaults.password_MaxLength)) else {
                errorValue = "Please enter a valid password should not be less than \(Defaults.password_MinLength) characters or more than \(Defaults.password_MaxLength) characters and password should be a combination of letters and numbers, it should have at least one letter and at least one number".localizedString
                return false;
            }
        }else {
            guard validateLength(text: data, size: (8,100)) else {
                errorValue = errorMessage
                return false;
            }
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
