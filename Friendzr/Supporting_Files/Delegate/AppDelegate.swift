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
//import SFaceCompare
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var badgeNumber:Int = 0
    static let geoCoder = CLGeocoder()
    let center = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display  notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
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
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
//        SFaceCompare.prepareData()

        if Defaults.isFirstLaunch == false {
            Defaults.allowMyLocation = true
        }
        
        Localizer.DoExchange()
        if Language.currentLanguage() == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }

        return true
    }
    
    
    //    @objc func newLocationAdded(_ notification: Notification) {
    //
    //    }
    
    // MARK: UISceneSession Lifecycle
    func applicationDidBecomeActive(_ application: UIApplication) {
        // reset badge count
        
        application.applicationIconBadgeNumber = 0
    }
    
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

        //        let snapDidHandle = SCSDKLoginClient.application(app, open: url, options: options)
        
//        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//              let annotation = options[UIApplication.OpenURLOptionsKey.annotation] else {
//                  return false
//              }
        
//        let TikTokDidHandle = TikTokOpenSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return googleDidHandle || facebookDidHandle //|| snapDidHandle || TikTokDidHandle
    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
//            return true
//        }
//        return false
//    }
    
//    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
//        if TikTokOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: nil, annotation: "") {
//            return true
//        }
//        return false
//    }
    
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
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                     -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // retrieve the root view controller (which is a tab bar controller)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard let rootViewController = Initializer.getWindow().rootViewController else {
                return
            }
            
            let userInfo = response.notification.request.content.userInfo
            
            _ = userInfo["aps"] as? [String:Any] //?[""]
            let action = userInfo["Action"] as? String //action transaction
            let actionId = userInfo["Action_code"] as? String //userid
            let chatTitle = userInfo["name"] as? String
            let chatTitleImage = userInfo["userimage"] as? String
//            let messageType = userInfo["Messagetype"] as? Int
            
            if action == "Friend_Request" {
                if let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.userID = actionId!
                    navController.pushViewController(vc, animated: true)
                }
            }else if action == "Accept_Friend_Request" {
                if let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.userID = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }else if action == "event_chat"{
                Router().toConversationVC(isEvent: true, eventChatID: actionId ?? "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: chatTitleImage ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1)
            }else if action == "user_chat"{
                Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: actionId ?? "", isFriend: true, titleChatImage: chatTitleImage ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1)
                
            }
            else if action == "user_chatGroup" {
                Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: chatTitleImage ?? "", titleChatName: chatTitle ?? "", isChatGroupAdmin: true, isChatGroup: true, groupId: actionId ?? "", leaveGroup: 0)
            }else if action == "Join Chat Group" {
                Router().toHome()
            }else if action == "Kickedout From Chat Group" {
                Router().toHome()
            }
            else if action == "event_Updated"{
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    //                    tabBarController.selectedIndex = 4
                    navController.pushViewController(vc, animated: true)
                }
            }else if action == "update_Event_Data"{
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }else if action == "event_attend"{
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }else if action == "Event_reminder" {
                if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.eventId = actionId ?? ""
                    navController.pushViewController(vc, animated: true)
                }
            }else if action == "Check_events_near_you" {
                if let vc = UIViewController.viewController(withStoryboard: .Map, AndContollerID: "MapVC") as? MapVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    tabBarController.selectedIndex = 1
                    navController.pushViewController(vc, animated: true)
                }
            }else {
                print("fail")
            }
        }
        
        completionHandler()
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
    }
}


extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        let dataDict:[String: String] = ["token": fcmToken!]
        print("Firebase registration token: \(String(describing: fcmToken))")
        Defaults.fcmToken = fcmToken!
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        let action = userInfo["Action"] as? String //action transaction
        if action == "user_chat" {
            NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
        }else if action == "event_chat" {
            NotificationCenter.default.post(name: Notification.Name("listenToMessagesForEvent"), object: nil, userInfo: nil)
        }else if action == "user_chatGroup" {
            NotificationCenter.default.post(name: Notification.Name("listenToMessagesForGroup"), object: nil, userInfo: nil)
        }
        
        
        // Change this to your preferred presentation option
        let isMute: String = userInfo["muit"] as? String ?? ""
        
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
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        
        if action == "user_chat" || action == "event_chat" || action == "user_chatGroup" {
            print("user_chat OR event_chat OR user_chatGroup")
        }else {
            Defaults.badgeNumber = UIApplication.shared.applicationIconBadgeNumber
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        let isMute: String = userInfo["muit"] as? String ?? ""
        let action = userInfo["Action"] as? String //action transaction

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
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        
        if action == "user_chat" || action == "event_chat" || action == "user_chatGroup" {
            print("user_chat Or event_chat")
        }else {
            Defaults.badgeNumber = UIApplication.shared.applicationIconBadgeNumber
        }
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
        
        //        let content = UNMutableNotificationContent()
        //        content.title = "New Location Entry 📌"
        //        content.body = location.description
        //        content.sound = UNNotificationSound.default
        //
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        //
        //        center.add(request, withCompletionHandler: nil)
        
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
