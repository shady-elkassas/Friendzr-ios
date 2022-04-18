//
//  AlertService.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/04/2022.
//

import Foundation
import UIKit


class AlertService {
    
    static func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "Ok", style: .cancel, handler: nil)], completion: (() -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alert.addAction(action)
        }
        
        UIApplication.shared.delegate?.window??.rootViewController?.present(alert, animated: true, completion: completion)
    }
}
