//
//  AppDelegate.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import FirebaseCrashlytics
import CoreLocation
import UserNotifications
//import SCSDKLoginKit
//import TikTokOpenSDK
import GoogleMobileAds
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var badgeNumber:Int = 0
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    let content = UNMutableNotificationContent()
    let fcmToken:String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().toolbarTintColor = UIColor.red
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!], for: .selected)
        
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 13, *) {
        } else {
            Router().toSplach()
        }
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        GMSServices.provideAPIKey("AIzaSyCLmWYc00w0KZ-qj8hIymWCIs8K5Z0cG0g")
        GMSPlacesClient.provideAPIKey("AIzaSyCLmWYc00w0KZ-qj8hIymWCIs8K5Z0cG0g")
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(registrationFCM), name: Notification.Name("registrationFCM"), object: nil)
        
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
//        self.configureNotification()
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
        
        networkReachability()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeApp), name: Notification.Name("updateBadgeApp"), object: nil)
        application.applicationIconBadgeNumber = 0
        
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
        }
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        
        // Uncomment following code to enable fake visits
        locationManager.distanceFilter = 500 // meter
        locationManager.allowsBackgroundLocationUpdates = true // 1
        locationManager.startUpdatingLocation()  // 2
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
        if Defaults.isFirstLaunch == false {
            Defaults.allowMyLocation = true
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
        }
        
        if UIScreen.main.nativeBounds.height < 2500 {
            Defaults.isIPhoneSmall = true
        }else {
            Defaults.isIPhoneSmall = false
        }
        
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.window?.makeKeyAndVisible()
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    }
    
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sourceApplication: String? = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        let googleDidHandle = GIDSignIn.sharedInstance.handle(url as URL)
        let facebookDidHandle = ApplicationDelegate.shared.application(app, open: url, sourceApplication: sourceApplication, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        return googleDidHandle || facebookDidHandle //|| snapDidHandle || TikTokDidHandle
    }
    
    func networkReachability() {
        do {
            try Network.reachability = Reachability(hostname: URLs.baseURLFirst)
        }
        catch {
            switch error as? Network.Error {
            case let .failedToCreateWith(hostname)?:
                print("Network error:\nFailed to create reachability object With host named:", hostname)
            case let .failedToInitializeWith(address)?:
                print("Network error:\nFailed to initialize reachability object With address:", address)
            case .failedToSetCallout?:
                print("Network error:\nFailed to set callout")
            case .failedToSetDispatchQueue?:
                print("Network error:\nFailed to set DispatchQueue")
            case .none:
                print(error)
            }
        }
    }
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Friendzr")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        print("Notification Data is : \(userInfo.debugDescription)")
        print("Notification Data is : \(userInfo.debugDescription)")
        let alert = UIAlertController(title: "", message: "\(userInfo.debugDescription)", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK".localizedString, style: .default, handler: { action in
            
        })
        let cancel = UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: { action in
        })
        alert.addAction(ok)
        alert.addAction(cancel)
        DispatchQueue.main.async(execute: {
            self.window?.rootViewController?.present(alert, animated: true)
        })
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let _: String = userInfo["sound"] as? String ?? ""
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updateMoreTableView"), object: nil, userInfo: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updateMoreTableView"), object: nil, userInfo: nil)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }
    
    @objc func updateBadgeApp() {
        let state = UIApplication.shared.applicationState
        
        switch state {
        case .inactive:
            print("Inactive")
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        case .background:
            print("Background")
            // update badge count here
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        case .active:
            print("Active")
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        default:
            break
        }
        
        content.sound = UNNotificationSound.default
    }
}

extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let _:[String: String] = ["token": fcmToken ?? ""]
        print("Firebase registration token: \(String(describing: fcmToken))")
        Defaults.fcmToken = fcmToken ?? ""
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: nil
        )
    }
    
    @objc func registrationFCM() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                Defaults.fcmToken = token
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        // retrieve the root view controller (which is a tab bar controller)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let rootViewController = Initializer.getWindow().rootViewController else {
                return
            }
            
            let userInfo = response.notification.request.content.userInfo
            
            let apsAlert = userInfo["aps"] as? [String:Any] //?[""]
            let title = apsAlert?["title"] as? String
            let body = apsAlert?["body"] as? String
            let action = userInfo["Action"] as? String //action transaction
            let actionId = userInfo["Action_code"] as? String //userid
            let chatTitle = userInfo["name"] as? String
            let chatTitleImage = userInfo["fcm_options"] as? [String:Any]
            let imageNotifications = chatTitleImage?["image"] as? String
            let isEventAdmin = userInfo["isAdmin"] as? String
            let messageType = userInfo["Messagetype"] as? Int
            
            self.content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "", content: self.content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
            
            if action == "Friend_Request" {
                if let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.userID = actionId!
                    navController.pushViewController(vc, animated: true)
                }
            }
            else if action == "Accept_Friend_Request" {
                if let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.userID = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }
            else if action == "event_chat"{
                if isEventAdmin == "False" {
                    Router().toConversationVC(isEvent: true, eventChatID: actionId ?? "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: imageNotifications ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1, isEventAdmin: false)
                }else {
                    Router().toConversationVC(isEvent: true, eventChatID: actionId ?? "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: imageNotifications ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1, isEventAdmin: true)
                }
            }
            else if action == "user_chat"{
                Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: actionId ?? "", isFriend: true, titleChatImage: imageNotifications ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1, isEventAdmin: false)
            }
            else if action == "user_chatGroup" {
                Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: imageNotifications ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: true, isChatGroup: true, groupId: actionId ?? "", leaveGroup: 0, isEventAdmin: false)
            }
            else if action == "Joined_ChatGroup" {
                Router().toHome()
            }
            else if action == "Kickedout_ChatGroup" {
                Router().toHome()
            }
            else if action == "event_Updated"{
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }
            else if action == "update_Event_Data"{
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }
            else if action == "event_attend"{
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }
            else if action == "Event_reminder" {
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }
            else if action == "Check_events_near_you" {
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }
            else {
                print("fail")
            }
        }
        
        completionHandler()
    }

    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        process(notification)
//        completionHandler([[.banner, .sound]])

        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
                
        let apsAlert = userInfo["aps"] as? [String:Any] //?[""]
        let alert = apsAlert?["alert"] as? [String:Any]
        let title = alert?["title"] as? String
        let body =  alert?["body"]  as? String
        
        let action = userInfo["Action"] as? String //action transaction
        let actionId = userInfo["Action_code"] as? String //userid
        let chatTitle = userInfo["name"] as? String
        let chatTitleImage = userInfo["fcm_options"] as? [String:Any]
        let imageNotifications = chatTitleImage?["image"] as? String
        let isEventAdmin = userInfo["isAdmin"] as? String
        let messageType = userInfo["Messagetype"] as? String
        let _: String = userInfo["sound"] as? String ?? ""

        self.content.sound = UNNotificationSound.default
        
        if messageType == "1" {//text
            self.content.title = title ?? ""
            self.content.body = body ?? ""
        }
        else if messageType == "2" {//image
            self.content.title = title ?? ""
//            self.content.body = "Image"
            
            if body != nil, let fileUrl = URL(string: imageNotifications!) {
                print("fileUrl: \(fileUrl)")
                do {
                    let attachment = try UNNotificationAttachment(identifier: "", url: fileUrl)
                    content.attachments = [ attachment ]
                }
                catch {
                    print("error attachment")
                }
            }
        }
        else if messageType == "3" {//file
            self.content.title = title ?? ""
            self.content.body = "File"
        }
        else if messageType == "4" {//share link
            self.content.title = title ?? ""
            self.content.body = "Link"
        }
        else {
            
        }
                
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: self.content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)

        if action == "user_chat" {
        }else if action == "event_chat" {
        }else if action == "user_chatGroup" {
        }else if action == "Friend_Request" {
            Defaults.frindRequestNumber += 1
            NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
        }else if action == "Accept_Friend_Request" {
            if Defaults.frindRequestNumber != 0 {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
            }
        }else if action == "Friend_request_cancelled" {
            if Defaults.frindRequestNumber != 0 {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
            }
        }else if action == "event_attend" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "Event_reminder" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "event_Updated" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "update_Event_Data" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "Check_events_near_you" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "Joined_ChatGroup" {
        }else if action == "Kickedout_ChatGroup" {
        }
        
        if action == "user_chat" {
            if Defaults.availableVC == "ConversationVC" {
                NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
            }else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        else if action == "event_chat" {
            if Defaults.availableVC == "ConversationVC" {
                NotificationCenter.default.post(name: Notification.Name("listenToMessagesForEvent"), object: nil, userInfo: nil)
            }else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        else if action == "user_chatGroup" {
            if Defaults.availableVC == "ConversationVC" {
                NotificationCenter.default.post(name: Notification.Name("listenToMessagesForGroup"), object: nil, userInfo: nil)
            }else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        
       
        if action == "Friend_Request" || action == "Accept_Friend_Request" || action == "Friend_request_cancelled" {
            if Defaults.availableVC == "RequestVC" {
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "FeedVC" {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "FriendProfileViewController" {
                NotificationCenter.default.post(name: Notification.Name("updateFriendVC"), object: nil, userInfo: nil)
            }
            
            NotificationCenter.default.post(name: Notification.Name("updateMoreTableView"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        }
        
        if action == "user_chat" || action == "event_chat" || action == "user_chatGroup" || action == "Friend_request_cancelled"{
            print("user_chat OR event_chat OR user_chatGroup")
        }
        else {
            Defaults.notificationcount = UIApplication.shared.applicationIconBadgeNumber
        }
        

        // Change this to your preferred presentation option
        let isMute: String = userInfo["muit"] as? String ?? ""
        
        if action == "Friend_request_cancelled" {
            completionHandler([[]])
        }
        else if Defaults.availableVC == "ConversationVC" {
            completionHandler([[]])
        }
        else if Defaults.pushnotification == false {
            completionHandler([[]])
        }
        else {
            if isMute == "False" {
                if #available(iOS 14.0, *) {
                    completionHandler([[.alert, .badge, .sound,.banner,.list]])
                } else {
                    // Fallback on earlier versions
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
            else {
                completionHandler([[]])
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let action = userInfo["Action"] as? String //action transaction
        let apsAlert = userInfo["aps"] as? [String:Any] //?[""]
//        let title = apsAlert?["title"] as? String
//        let body = apsAlert?["body"] as? String
//        let actionId = userInfo["Action_code"] as? String //userid
//        let chatTitle = userInfo["name"] as? String
//        let chatTitleImage = userInfo["fcm_options"] as? [String:Any]
//        let imageNotifications = chatTitleImage?["image"] as? String
//        let isEventAdmin = userInfo["isAdmin"] as? String
//        let messageType = userInfo["Messagetype"] as? String
//        let _: String = userInfo["sound"] as? String ?? ""

        self.content.sound = UNNotificationSound.default
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        let request = UNNotificationRequest(identifier: "", content: self.content, trigger: trigger)
//        center.add(request, withCompletionHandler: nil)

//        if messageType == "1" {//text
//            self.content.title = title ?? ""
//            self.content.body = body ?? ""
//        }else if messageType == "2" {//image
//            self.content.title = title ?? ""
//            self.content.body = "Image"
//        }else if messageType == "3" {//file
//            self.content.title = title ?? ""
//            self.content.body = "File"
//        }else if messageType == "4" {//share link
//            self.content.title = title ?? ""
//            self.content.body = "Link"
//        }else {
//
//        }

        
        if action == "user_chat" {
        }else if action == "event_chat" {
        }else if action == "user_chatGroup" {
        }else if action == "Friend_Request" {
            Defaults.frindRequestNumber += 1
            NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
        }else if action == "Accept_Friend_Request" {
            if Defaults.frindRequestNumber != 0 {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
            }
        }else if action == "Friend_request_cancelled" {
            if Defaults.frindRequestNumber != 0 {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
            }
        }else if action == "event_attend" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "Event_reminder" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "event_Updated" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "update_Event_Data" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "Check_events_near_you" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }else if action == "Joined_ChatGroup" {
        }else if action == "Kickedout_ChatGroup" {
        }
        
        if action == "user_chat" {
            if Defaults.availableVC == "ConversationVC" {
                NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
            }else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        else if action == "event_chat" {
            if Defaults.availableVC == "ConversationVC" {
                NotificationCenter.default.post(name: Notification.Name("listenToMessagesForEvent"), object: nil, userInfo: nil)
            }else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        else if action == "user_chatGroup" {
            if Defaults.availableVC == "ConversationVC" {
                NotificationCenter.default.post(name: Notification.Name("listenToMessagesForGroup"), object: nil, userInfo: nil)
            }else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        
       
        if action == "Friend_Request" || action == "Accept_Friend_Request" || action == "Friend_request_cancelled" {
            if Defaults.availableVC == "RequestVC" {
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "FeedVC" {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "FriendProfileViewController" {
                NotificationCenter.default.post(name: Notification.Name("updateFriendVC"), object: nil, userInfo: nil)
            }
            
            NotificationCenter.default.post(name: Notification.Name("updateMoreTableView"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        }
        
        if action == "user_chat" || action == "event_chat" || action == "user_chatGroup" || action == "Friend_request_cancelled" {
            print("user_chat OR event_chat OR user_chatGroup")
        }
        else {
            Defaults.notificationcount = UIApplication.shared.applicationIconBadgeNumber
        }

        // Change this to your preferred presentation option
        let isMute: String = userInfo["muit"] as? String ?? ""
        
        if action == "Friend_request_cancelled" {
            completionHandler([[]])
        }
        else if Defaults.availableVC == "ConversationVC" {
            completionHandler([[]])
        }
        else if Defaults.pushnotification == false {
            completionHandler([[]])
        }
        else {
            if isMute == "False" {
                if #available(iOS 14.0, *) {
                    completionHandler([[.alert, .badge, .sound,.banner,.list]])
                } else {
                    // Fallback on earlier versions
                    completionHandler([[.alert, .badge, .sound]])
                }
            }
            else {
                completionHandler([[]])
            }
        }
      
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // create CLLocation from the coordinates of CLVisit
        let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
        
        // Get location description
        AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "\(place)"
                self.newVisitReceived(visit, description: description)
            }
        }
    }
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        let location = Location(visit: visit, descriptionString: description)
        LocationsStorage.shared.saveLocationOnDisk(location)
        
//                let content = UNMutableNotificationContent()
//                content.title = "New Location Entry 📌"
//                content.body = location.description
//                content.sound = UNNotificationSound.default
//
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//                let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
//                center.add(request, withCompletionHandler: nil)
        
        if Defaults.availableVC == "FeedVC" || Defaults.availableVC == "MapVC" {
            self.checkLocationPermission()
        }
        
        //update location server
        self.updateLocationVM.updatelocation(ByLat: "\(location.latitude)", AndLng: "\(location.longitude)") { error, data in
            if let error = error {
                print(error)
                return
            }
            
            guard let _ = data else {return}
            Defaults.LocationLat = "\(location.latitude)"
            Defaults.LocationLng = "\(location.longitude)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        Defaults.LocationLat = "\(location.coordinate.latitude)"
        Defaults.LocationLng = "\(location.coordinate.longitude)"
        
        print("Defaults.LocationLat\(Defaults.LocationLat),Defaults.LocationLng\(Defaults.LocationLng)")
        
        AppDelegate.geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                let description = "Fake visit: \(place)"
                
                let fakeVisit = FakeVisit(coordinates: location.coordinate, arrivalDate: Date(), departureDate: Date())
                self.newVisitReceived(fakeVisit, description: description)
            }
        }
    }
}

final class FakeVisit: CLVisit {
    private let myCoordinates: CLLocationCoordinate2D
    private let myArrivalDate: Date
    private let myDepartureDate: Date
    
    override var coordinate: CLLocationCoordinate2D {
        return myCoordinates
    }
    
    override var arrivalDate: Date {
        return myArrivalDate
    }
    
    override var departureDate: Date {
        return myDepartureDate
    }
    
    init(coordinates: CLLocationCoordinate2D, arrivalDate: Date, departureDate: Date) {
        myCoordinates = coordinates
        myArrivalDate = arrivalDate
        myDepartureDate = departureDate
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//let notificationManager = NotificationManager.shared
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(newLocationAdded(_:)),
//            name: .newLocationSaved,
//            object: nil)

//        if Defaults.darkMode == true {
//            UIApplication.shared.windows.forEach { window in
//                window.overrideUserInterfaceStyle = .dark
//            }
//        }else {
//            UIApplication.shared.windows.forEach { window in
//                window.overrideUserInterfaceStyle = .light
//            }
//        }


extension AppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application, and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_UIApplicationDidBecomeActiveNotification application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                locationManager.stopUpdatingLocation()
                Defaults.allowMyLocationSettings = false
                if Defaults.availableVC == "MapVC" {
                    NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
                }
                else if Defaults.availableVC == "FeedVC" {
                    NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                }
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                locationManager.startUpdatingLocation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if Defaults.availableVC == "MapVC" {
                        NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
                    }
                    else if Defaults.availableVC == "FeedVC" {
                        NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                    }
                }
            default:
                break
            }
        }
        else {
            print("Location services are not enabled")
            Defaults.allowMyLocationSettings = false
        }
        
    }
}
