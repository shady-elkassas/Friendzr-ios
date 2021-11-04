//
//  EmailViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

class EmailViewModel : ValidationViewModel{
    var errorValue: String?
    var errorMessage: String = "Please enter a valid Email".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
        
        guard validatePattern(text: data) else {
            errorValue = errorMessage
            return false
        }
        
        errorValue = ""
        return true
    }
    
    func validatePattern(text : String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
}

