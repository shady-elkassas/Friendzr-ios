//
//  ValidationViewModel.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 29/08/2021.
//

import Foundation

protocol ValidationViewModel {
     
    var errorMessage: String { get }
    
    // Observables
    var data: String { get set }
    var errorValue: String? { get}
    
    // Validation
    func validateCredentials() -> Bool
}

protocol ValidationsViewModel {
     
    var errorMessage: String { get }
    
    // Observables
    var data: [String] { get set }
    var errorValue: String? { get}
    
    // Validation
    func validateCredentials() -> Bool
}
