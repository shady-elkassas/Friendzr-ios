//
//  SceneDelegate.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import CoreLocation
import AppsFlyerLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let content = UNMutableNotificationContent()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 11)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 11)!], for: .selected)
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: nil)
        
        //        if Defaults.darkMode == true {
        //            UIApplication.shared.windows.forEach { window in
        //                window.overrideUserInterfaceStyle = .dark
        //            }
        //        }else {
        //            UIApplication.shared.windows.forEach { window in
        //                window.overrideUserInterfaceStyle = .light
        //            }
        //        }
//        Localizer.DoExchange()
//        if Language.currentLanguage() == "ar" {
//            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//        }else{
//            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//        }
        
//        self.content.sound = UNNotificationSound.default
        if let userActivity = connectionOptions.userActivities.first {
            NSLog("[AFSDK] 4. Processing Universal Link from the killed state")
            AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        } else if let url = connectionOptions.urlContexts.first?.url {
            NSLog("[AFSDK] 5. Processing URI scheme from the killed state")
            AppsFlyerLib.shared().handleOpen(url, options: nil)
        }


        guard let _ = (scene as? UIWindowScene) else { return }
        Router().toSplach()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }
        
        AppsFlyerLib.shared().handleOpen(url, options: nil)
        
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: nil,
            annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        NSLog("[AFSDK] 1. %@", "scene with Universal Link")
        // Universal Link - Background -> foreground
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }

}
