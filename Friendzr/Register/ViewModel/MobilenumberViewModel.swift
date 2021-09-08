//
//  MobilenumberViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

class MobilenumberViewModel {
    var errorValue: String?
    var errorMessage: String = "Please enter a valid mobile number".localizedString
    var data: String = ""
    
    func validateCredentials() -> Bool {
         guard validateLength(text: data, size: (9,15)) else {
          errorValue = errorMessage
          return false;
        }
     
        guard isAllDigits(text: data) else {
            errorValue = errorMessage
            return false
        }
        errorValue = ""
        return  true //predicate.evaluate(with: data)
   
    }
    private func validateLength(text : String, size : (min : Int, max : Int)) -> Bool{
        return (size.min...size.max).contains(text.count)
    }
    private func isAllDigits(text:String)->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = text.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  text == filtered
    }

}
