//
//  Initializer.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

class Initializer {
    
    class func getStoryboard(WithName name:StoryBoard) -> UIStoryboard {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        return storyboard
    }
    
    class func getWindow() -> UIWindow {
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            let window = appDelegate.window
            return window!
        } else {
            // Fallback on earlier versions
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let window = appDelegate.window
            return window!
        }
    }
    
    class func createViewController(storyBoard:StoryBoard,andId id:String) -> UIViewController {
        let storyboard = getStoryboard(WithName: storyBoard)
        if #available(iOS 13.0, *) {
            let vc = storyboard.instantiateViewController(identifier: id)
            return vc
        } else {
            // Fallback on earlier versions
            let vc = storyboard.instantiateViewController(withIdentifier: id) //instantiateViewController(identifier: id)
            return vc
        }
        
    }
    
}
