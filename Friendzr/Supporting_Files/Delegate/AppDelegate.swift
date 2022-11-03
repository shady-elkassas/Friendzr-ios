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
import AWSCore
import SwiftUI
import FBAudienceNetwork
import AppTrackingTransparency
import AppsFlyerLib

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
    var userInfoo: [AnyHashable: Any] = [AnyHashable: Any]()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FBAdSettings.setAdvertiserTrackingEnabled(true)
        
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().toolbarTintColor = UIColor.FriendzrColors.primary
        IQKeyboardManager.shared().isEnableAutoToolbar = true
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.color("#241332")!], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Montserrat-Medium", size: 14)!], for: .selected)
        setupHeightApp()
        
        
        let ads = GADMobileAds.sharedInstance()
        ads.start(completionHandler: nil)
        ads.start { status in
            // Optional: Log each adapter's initialization latency.
            let adapterStatuses = status.adapterStatusesByClassName
            for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                      adapterStatus.description, adapterStatus.latency)
            }
            
            // Start loading ads here...
        }
        
        // Initialize Identity Provider //AWS
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .USEast1,
            identityPoolId: "us-east-1:3f882f36-c5be-49a1-aa6f-de424d980388")
        let configuration = AWSServiceConfiguration(
            region: .USEast1,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        
        if #available(iOS 13, *) {
        } else {
            Router().toSplach()
        }
        
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        GMSServices.provideAPIKey("AIzaSyCLmWYc00w0KZ-qj8hIymWCIs8K5Z0cG0g")
        GMSPlacesClient.provideAPIKey("AIzaSyCLmWYc00w0KZ-qj8hIymWCIs8K5Z0cG0g")
        
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
        
        Messaging.messaging().delegate = self
        application.registerForRemoteNotifications()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
        center.requestAuthorization(options: [.alert, .sound,.badge]) { granted, error in
        }
        center.add(request, withCompletionHandler: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeApp), name: Notification.Name("updateBadgeApp"), object: nil)
        application.applicationIconBadgeNumber = 0
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .light
        }
        
        if Defaults.isFirstLaunch == false {
            Defaults.allowMyLocation = true
        }
        
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.window?.makeKeyAndVisible()
        
//        Defaults.isSubscribe = false
        
        setupUpdateLocation()
        
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("enable tracking")
                case .denied:
                    print("disable tracking")
                default:
                    print("disable tracking")
                }
            }
        }
        
        setupAppsFlyer()
        
//        if let launchOptions = launchOptions, let userInfo =  launchOptions[.remoteNotification] as? [AnyHashable: Any] {
//            print(userInfo)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                guard let rootViewController = Initializer.getWindow().rootViewController else {
//                    return
//                }
//
//                Messaging.messaging().appDidReceiveMessage(userInfo)
//                let action = userInfo["Action"] as? String //action transaction
//                let actionId = userInfo["Action_code"] as? String //userid
//                let chatTitle = userInfo["name"] as? String
//                let imageNotifications = userInfo["ImageUrl"] as? String
//                let isEventAdmin = userInfo["isAdmin"] as? String
//                //            let messageType = userInfo["Messagetype"] as? Int
//                _ = userInfo["messsageLinkEvenMyEvent"] as? String ?? ""
//
//                self.content.badge = 0
//                self.redirectNotification(action, rootViewController, actionId, isEventAdmin, imageNotifications, chatTitle)
//            }
//        }
        
        return true
    }

    func setupAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "vsg4WBcUHeJBLTpcHDpuJ"
        AppsFlyerLib.shared().appleAppID = "id1585963463"
        AppsFlyerLib.shared().delegate = self
        //  Set isDebug to true to see AppsFlyer debug logs
        AppsFlyerLib.shared().isDebug = true
        
        if #available(iOS 14, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { (status) in
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        AppsFlyerLib.shared().deepLinkDelegate = self

        NotificationCenter.default.addObserver(self,selector: #selector(didBecomeActiveNotification),name: UIApplication.didBecomeActiveNotification,object: nil)
    }
    
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
    
    @objc func didBecomeActiveNotification() {
        // start is usually called here:
        // AppsFlyerLib.shared().start()
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .denied:
                    print("AuthorizationSatus is denied")
                case .notDetermined:
                    print("AuthorizationSatus is notDetermined")
                case .restricted:
                    print("AuthorizationSatus is restricted")
                case .authorized:
                    print("AuthorizationSatus is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    
    func setupUpdateLocation() {
        locationManager.requestAlwaysAuthorization()
        //        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startMonitoringVisits()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startMonitoringSignificantLocationChanges()
        
        // Uncomment following code to enable fake visits
        locationManager.distanceFilter = 500 // meter
        locationManager.allowsBackgroundLocationUpdates = true // 1
        //        locationManager.startUpdatingLocation()  // 2
        //        var timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
        let status = CLLocationManager.authorizationStatus()
        
        if CLLocationManager.locationServicesEnabled() {
            switch status {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                locationManager.stopUpdatingLocation()
                Defaults.allowMyLocationSettings = false
            case .authorizedAlways:
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.startUpdatingLocation()
                }
                Defaults.allowMyLocationSettings = true
            case .authorizedWhenInUse:
                locationManager.stopUpdatingLocation()
                Defaults.allowMyLocationSettings = true
            default:
                break
            }
        }
        
    }
    
    // MARK: UISceneSession Lifecycle
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
        
        AppsFlyerLib.shared().handleOpen(url, options: options)
        
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
    
    func setupHeightApp() {
        if UIScreen.main.nativeBounds.height < 1500 {
            Defaults.isIPhoneLessThan1500 = true
        }else {
            Defaults.isIPhoneLessThan1500 = false
        }
        
        if UIScreen.main.nativeBounds.height < 2500 {
            Defaults.isIPhoneLessThan2500 = true
        }else {
            Defaults.isIPhoneLessThan2500 = false
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
        //        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
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
        
        AppsFlyerLib.shared().handlePushNotification(userInfo)
        
        NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
        
        locationManager.startUpdatingLocation()
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("deviceToken = \(deviceToken)")
        registrationFCM()
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
        
        let _:[String: String] = ["token": fcmToken ?? ""]
        print("Firebase registration token: \(String(describing: fcmToken))")
        Defaults.fcmToken = fcmToken ?? ""
        
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: nil
        )
        
        registrationFCM()
    }
    
    @objc func registrationFCM() {
        Messaging.messaging().isAutoInitEnabled = true
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
            Messaging.messaging().appDidReceiveMessage(userInfo)
            let action = userInfo["Action"] as? String //action transaction
            let actionId = userInfo["Action_code"] as? String //userid
            let chatTitle = userInfo["name"] as? String
            let imageNotifications = userInfo["ImageUrl"] as? String
            let isEventAdmin = userInfo["isAdmin"] as? String
            //            let messageType = userInfo["Messagetype"] as? Int
            _ = userInfo["messsageLinkEvenMyEvent"] as? String ?? ""
            
            //            self.content.sound = UNNotificationSound.default
            self.content.badge = 0
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "", content: self.content, trigger: trigger)
            center.add(request, withCompletionHandler: nil)
            
            
            self.redirectNotification(action, rootViewController, actionId, isEventAdmin, imageNotifications, chatTitle)
        }
        
        completionHandler()
    }
    
    // Receive displayed notifications for iOS 10 devices.
    //For FOREGROUND state
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        let apsAlert = userInfo["aps"] as? [String:Any] //?[""]
        let alert = apsAlert?["alert"] as? [String:Any]
        let body =  alert?["body"]  as? String
        let action = userInfo["Action"] as? String //action transaction
        let actionId = userInfo["Action_code"] as? String //userid
        let messageType = userInfo["Messagetype"] as? String
        let _: String = userInfo["sound"] as? String ?? ""
        let messageTime = userInfo["time"] as? String ?? ""
        let messagedate = userInfo["date"] as? String ?? ""
        let IsWhitelabel = userInfo["IsWhitelabel"] as? String ?? ""
        let messsageImageURL = userInfo["messsageImageURL"] as? String ?? ""
        let messsageLinkEvenImage = userInfo["messsageLinkEvenImage"] as? String ?? ""
        let messsageLinkEvenTitle = userInfo["messsageLinkEvenTitle"] as? String ?? ""
        _ = userInfo["messsageLinkEvencategorieimage"] as? String ?? ""
        let messsageLinkEventotalnumbert = userInfo["messsageLinkEventotalnumbert"] as? String ?? ""
        let messsageLinkEvenId = userInfo["messsageLinkEvenId"] as? String ?? ""
        let senderId = userInfo["senderId"] as? String ?? ""
        let messsageLinkEvenkey = userInfo["messsageLinkEvenkey"] as? String ?? ""
        let messageId = userInfo["messageId"] as? String ?? ""
        let _ = userInfo["messsageLinkEvenMyEvent"] as? String ?? ""
        let messsageLinkEvenjoined = userInfo["messsageLinkEvenjoined"] as? String ?? ""
        let messsageLinkEveneventdateto = userInfo["messsageLinkEveneventdateto"] as? String ?? ""
        let messsageLinkEvencategorie = userInfo["messsageLinkEvencategorie"] as? String ?? ""
        
        let senderImage = userInfo["senderImage"] as? String ?? ""
        let senderDisplayName = userInfo["senderDisplayName"] as? String ?? ""
        
        
        var isWhiteLabel:Bool = false
        if IsWhitelabel == "True" {
            isWhiteLabel = true
        }else {
            isWhiteLabel = false
        }
        
        if Defaults.availableVC == "MessagesVC" || Defaults.ConversationID == actionId{
            notificationMessageChat(messageType, action, actionId, body, messageId, messagedate, messageTime, senderId, senderImage, senderDisplayName, messsageImageURL, messsageLinkEvenkey, messsageLinkEvenTitle, messsageLinkEvencategorie, messsageLinkEvenImage, messsageLinkEvenjoined, messsageLinkEventotalnumbert, messsageLinkEveneventdateto, messsageLinkEvenId,isWhiteLabel)
        }
        
        updateAppWhenPresentNotification(action, actionId)
        
        // Change this to your preferred presentation option
        let isMute: String = userInfo["muit"] as? String ?? ""
        setupMuteNotification(action, actionId, isMute,completionHandler)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: self.content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
        
    }
    
    //For BACKGROUND state
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        self.content.badge = 0
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        let apsAlert = userInfo["aps"] as? [String:Any] //?[""]
        let alert = apsAlert?["alert"] as? [String:Any]
        //        let title = alert?["title"] as? String
        let body =  alert?["body"]  as? String
        
        let action = userInfo["Action"] as? String //action transaction
        let actionId = userInfo["Action_code"] as? String //userid
        //        let chatTitle = userInfo["name"] as? String
        //        let chatTitleImage = userInfo["fcm_options"] as? [String:Any]
        //        let imageNotifications = chatTitleImage?["image"] as? String
        //        let isEventAdmin = userInfo["isAdmin"] as? String
        let messageType = userInfo["Messagetype"] as? String
        let _: String = userInfo["sound"] as? String ?? ""
        let messageTime = userInfo["time"] as? String ?? ""
        let messagedate = userInfo["date"] as? String ?? ""
        let IsWhitelabel = userInfo["IsWhitelabel"] as? String ?? ""

        let messsageImageURL = userInfo["messsageImageURL"] as? String ?? ""
        let messsageLinkEvenImage = userInfo["messsageLinkEvenImage"] as? String ?? ""
        let messsageLinkEvenTitle = userInfo["messsageLinkEvenTitle"] as? String ?? ""
        _ = userInfo["messsageLinkEvencategorieimage"] as? String ?? ""
        let messsageLinkEventotalnumbert = userInfo["messsageLinkEventotalnumbert"] as? String ?? ""
        let messsageLinkEvenId = userInfo["messsageLinkEvenId"] as? String ?? ""
        let senderId = userInfo["senderId"] as? String ?? ""
        let messsageLinkEvenkey = userInfo["messsageLinkEvenkey"] as? String ?? ""
        let messageId = userInfo["messageId"] as? String ?? ""
        let _ = userInfo["messsageLinkEvenMyEvent"] as? String ?? ""
        let messsageLinkEvenjoined = userInfo["messsageLinkEvenjoined"] as? String ?? ""
        let messsageLinkEveneventdateto = userInfo["messsageLinkEveneventdateto"] as? String ?? ""
        let messsageLinkEvencategorie = userInfo["messsageLinkEvencategorie"] as? String ?? ""
        
        let senderImage = userInfo["senderImage"] as? String ?? ""
        let senderDisplayName = userInfo["senderDisplayName"] as? String ?? ""
        
        var isWhiteLabel:Bool = false
        if IsWhitelabel == "True" {
            isWhiteLabel = true
        }else {
            isWhiteLabel = false
        }
        
        if Defaults.availableVC == "MessagesVC" || Defaults.ConversationID == actionId {
            notificationMessageChat(messageType, action, actionId, body, messageId, messagedate, messageTime, senderId, senderImage, senderDisplayName, messsageImageURL, messsageLinkEvenkey, messsageLinkEvenTitle, messsageLinkEvencategorie, messsageLinkEvenImage, messsageLinkEvenjoined, messsageLinkEventotalnumbert, messsageLinkEveneventdateto, messsageLinkEvenId, isWhiteLabel)
        }
        
        updateAppWhenPresentNotification(action, actionId)
        
        // Change this to your preferred presentation option
        let isMute: String = userInfo["muit"] as? String ?? ""
        setupMuteNotification(action, actionId, isMute,completionHandler)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "", content: self.content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
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
        
        //        let content = UNMutableNotificationContent()
        //        content.title = "New Location Entry 📌"
        //        content.body = location.description
        //        content.sound = UNNotificationSound.default
        
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //        let request = UNNotificationRequest(identifier: location.dateString, content: content, trigger: trigger)
        //        center.add(request, withCompletionHandler: nil)
        
        //update location server
        if Defaults.token != "" {
            self.updateLocationVM.updatelocation(ByLat: "\(location.latitude)", AndLng: "\(location.longitude)") { error, data in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let _ = data else {return}
                Defaults.LocationLat = "\(location.latitude)"
                Defaults.LocationLng = "\(location.longitude)"
            }
        }else {
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
    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
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

extension AppDelegate {
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application, and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_UIApplicationDidBecomeActiveNotification application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        setupUpdateLocation()
        AppsFlyerLib.shared().start()
        //        FIRMessaging.messaging().disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
    }
    
    //    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
    //
    //    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
        registrationFCM()
        AppsFlyerLib.shared().start()
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
                locationManager.showsBackgroundLocationIndicator = false
                
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

extension AppDelegate {
    func redirectNotification(_ action: String?, _ rootViewController: UIViewController, _ actionId: String?, _ isEventAdmin: String?, _ imageNotifications: String?, _ chatTitle: String?) {
        if action == "Friend_Request" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.userID = actionId!
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "Accept_Friend_Request" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.userID = actionId ?? ""
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "event_chat"{
            if isEventAdmin == "False" {
                if let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.isEvent = true
                    vc.eventChatID = actionId ?? ""
                    vc.chatuserID = ""
                    vc.leavevent = 0
                    vc.leaveGroup =  0
                    vc.isFriend = false
                    vc.titleChatImage = imageNotifications ?? ""
                    vc.titleChatName = chatTitle ?? ""
                    vc.isChatGroupAdmin = false
                    vc.isChatGroup = false
                    vc.groupId = ""
                    vc.isEventAdmin = false
                    navController.pushViewController(vc, animated: true)
                }
            }
            else {
                if let vc = MessagesVC.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC,
                   let tabBarController = rootViewController as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    vc.isEvent = true
                    vc.eventChatID = actionId ?? ""
                    vc.chatuserID = ""
                    vc.leavevent = 0
                    vc.leaveGroup =  0
                    vc.isFriend = false
                    vc.titleChatImage = imageNotifications ?? ""
                    vc.titleChatName = chatTitle ?? ""
                    vc.isChatGroupAdmin = false
                    vc.isChatGroup = false
                    vc.groupId = ""
                    vc.isEventAdmin = true
                    navController.pushViewController(vc, animated: true)
                }
            }
        }
        else if action == "user_chat" {
            if let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.isEvent = false
                vc.eventChatID = ""
                vc.chatuserID = actionId ?? ""
                vc.leavevent = 0
                vc.leaveGroup =  0
                vc.isFriend = true
                vc.titleChatImage = imageNotifications ?? ""
                vc.titleChatName = chatTitle ?? ""
                vc.isChatGroupAdmin = false
                vc.isChatGroup = false
                vc.groupId = ""
                vc.isEventAdmin = false
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "user_chatGroup" {
            if let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.isEvent = false
                vc.eventChatID = ""
                vc.chatuserID = ""
                vc.leavevent = 1
                vc.leaveGroup =  0
                vc.isFriend = false
                vc.titleChatImage = imageNotifications ?? ""
                vc.titleChatName = chatTitle ?? ""
                vc.isChatGroupAdmin = true
                vc.isChatGroup = true
                vc.groupId = actionId ?? ""
                vc.isEventAdmin = false
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "Joined_ChatGroup" && !Defaults.isWhiteLable {
            Router().toHome()
        }
        else if action == "Kickedout_ChatGroup" && !Defaults.isWhiteLable {
            Router().toHome()
        }
        else if action == "event_Updated" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.eventId = actionId ?? ""
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "update_Event_Data" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.eventId = actionId ?? ""
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "event_attend" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.eventId = actionId ?? ""
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "Event_reminder" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.eventId = actionId ?? ""
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "Check_events_near_you" && !Defaults.isWhiteLable {
            if let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController,
               let tabBarController = rootViewController as? UITabBarController,
               let navController = tabBarController.selectedViewController as? UINavigationController {
                vc.eventId = actionId ?? ""
                navController.pushViewController(vc, animated: true)
            }
        }
        else if action == "Check_private_events" && !Defaults.isWhiteLable {
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
    
    func updateAppWhenPresentNotification(_ action: String?, _ actionId: String?) {
        if action == "Friend_Request" {
            Defaults.frindRequestNumber += 1
            NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
        }
        else if action == "Accept_Friend_Request" {
            if Defaults.frindRequestNumber != 0 {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
        }
        else if action == "Friend_request_cancelled" {
            if Defaults.frindRequestNumber != 0 {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
        }
        else if action == "event_attend" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }
        else if action == "Event_reminder" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }
        else if action == "event_Updated" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }
        else if action == "update_Event_Data" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }
        else if action == "Check_events_near_you" {
            if Defaults.availableVC == "EventDetailsViewController" {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }
        else if action == "Joined_ChatGroup" {
        }
        else if action == "Kickedout_ChatGroup" {
        }
        
        if action == "user_chat" {
            if Defaults.availableVC == "MessagesVC" || Defaults.ConversationID == actionId {
                NotificationCenter.default.post(name: Notification.Name("listenToMessages"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        else if action == "event_chat" {
            if Defaults.availableVC == "MessagesVC" || Defaults.ConversationID == actionId {
                NotificationCenter.default.post(name: Notification.Name("listenToMessagesForEvent"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "InboxVC" {
                NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
            }
        }
        else if action == "user_chatGroup" {
            if Defaults.availableVC == "MessagesVC" || Defaults.ConversationID == actionId{
                NotificationCenter.default.post(name: Notification.Name("listenToMessagesForGroup"), object: nil, userInfo: nil)
            }
            else if Defaults.availableVC == "InboxVC" {
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
        }
        
        if action == "user_chat" || action == "event_chat" || action == "user_chatGroup" || action == "Friend_request_cancelled" {
        }
        else {
            NotificationCenter.default.post(name: Notification.Name("updateBadgeApp"), object: nil, userInfo: nil)
            Defaults.notificationcount = UIApplication.shared.applicationIconBadgeNumber
            NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
        }
        
        
        //badge inbox
        if action == "user_chat" ||  action == "event_chat" || action == "user_chatGroup" {
            if Defaults.availableVC != "MessagesVC" || Defaults.ConversationID != actionId {
                
                Defaults.message_Count += 1
                NotificationCenter.default.post(name: Notification.Name("updatebadgeInbox"), object: nil, userInfo: nil)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("reloadChatList"), object: nil, userInfo: nil)
                }
            }
        }
    }
    func setupMuteNotification(_ action: String?, _ actionId: String?, _ isMute: String,_ completionHandler: (UNNotificationPresentationOptions) -> Void) {
        if Defaults.pushnotification == false {
            completionHandler([[]])
        }
        else {
            if action == "Friend_request_cancelled" || action == "Friend_block" {
                completionHandler([[]])
            }
            else if Defaults.availableVC == "MessagesVC" && Defaults.ConversationID == actionId
            {
                completionHandler([[]])
            }
            else if Defaults.isWhiteLable && action != "event_chat" {
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
    }
    
    func notificationMessageChat(_ messageType: String?, _ action: String?, _ actionId: String?, _ body: String?, _ messageId: String, _ messagedate: String, _ messageTime: String, _ senderId: String, _ senderImage: String, _ senderDisplayName: String, _ messsageImageURL: String, _ messsageLinkEvenkey: String, _ messsageLinkEvenTitle: String, _ messsageLinkEvencategorie: String, _ messsageLinkEvenImage: String, _ messsageLinkEvenjoined: String, _ messsageLinkEventotalnumbert: String, _ messsageLinkEveneventdateto: String, _ messsageLinkEvenId: String, _ isWhitelabel:Bool ) {
        
        if messageType == "1" {//text
            NotificationMessage.action = action ?? ""
            NotificationMessage.actionCode = actionId ?? ""
            NotificationMessage.messageType = 1
            NotificationMessage.messageText = body ?? ""
            NotificationMessage.messageId = messageId
            NotificationMessage.messageDate = messagedate
            NotificationMessage.messageTime = messageTime
            NotificationMessage.senderId = senderId
            NotificationMessage.photoURL = senderImage
            NotificationMessage.displayName = senderDisplayName
            NotificationMessage.isWhitelabel = isWhitelabel
        }
        else if messageType == "2" {//image
            NotificationMessage.action = action ?? ""
            NotificationMessage.actionCode = actionId ?? ""
            NotificationMessage.messageType = 2
            NotificationMessage.messsageImageURL = messsageImageURL
            NotificationMessage.messageId = messageId
            NotificationMessage.messageDate = messagedate
            NotificationMessage.messageTime = messageTime
            NotificationMessage.senderId = senderId
            NotificationMessage.photoURL = senderImage
            NotificationMessage.displayName = senderDisplayName
            NotificationMessage.isWhitelabel = isWhitelabel
        }
        else if messageType == "3" {//file
            NotificationMessage.action = action ?? ""
            NotificationMessage.actionCode = actionId ?? ""
            NotificationMessage.messageType = 3
            NotificationMessage.messsageImageURL = messsageImageURL
            NotificationMessage.messageId = messageId
            NotificationMessage.messageDate = messagedate
            NotificationMessage.messageTime = messageTime
            NotificationMessage.photoURL = senderImage
            NotificationMessage.senderId = senderId
            NotificationMessage.displayName = senderDisplayName
            NotificationMessage.isWhitelabel = isWhitelabel
        }
        else if messageType == "4" {//link preview
            NotificationMessage.action = action ?? ""
            NotificationMessage.actionCode = actionId ?? ""
            NotificationMessage.messageType = 4
            NotificationMessage.senderId = senderId
            NotificationMessage.messageId = messageId
            NotificationMessage.messageDate = messagedate
            NotificationMessage.messageTime = messageTime
            NotificationMessage.photoURL = senderImage
            NotificationMessage.displayName = senderDisplayName
            NotificationMessage.isJoinEvent = Int(messsageLinkEvenkey) ?? 0
            NotificationMessage.messsageLinkTitle = messsageLinkEvenTitle
            NotificationMessage.messsageLinkCategory = messsageLinkEvencategorie
            NotificationMessage.messsageLinkImageURL = messsageLinkEvenImage
            NotificationMessage.messsageLinkAttendeesJoined = messsageLinkEvenjoined
            NotificationMessage.messsageLinkAttendeesTotalnumbert = messsageLinkEventotalnumbert
            NotificationMessage.messsageLinkEventDate = messsageLinkEveneventdateto
            NotificationMessage.linkPreviewID = messsageLinkEvenId
            NotificationMessage.isWhitelabel = isWhitelabel
        }
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    
    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        
        print("onConversionDataSuccess data:")
        for (key, value) in data {
            print(key, ":", value)
        }
        
        if let status = data["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = data["media_source"],
                   let campaign = data["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = data["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
                
            } else {
                print("Not First Launch")
            }
        }
    }
    
    func onConversionDataFail(_ error: Error) {
        print("\(error)")
    }
    
    // Handle Deeplink
    func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {
        //Handle Deep Link Data
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    
    func onAppOpenAttributionFailure(_ error: Error) {
        print("\(error)")
    }
}


extension AppDelegate: DeepLinkDelegate {
//    func didResolveDeepLink(_ result: DeepLinkResult) {
//        var fruitNameStr: String?
//        switch result.status {
//        case .notFound:
//            NSLog("[AFSDK] Deep link not found")
//            return
//        case .failure:
//            print("Error %@", result.error!)
//            return
//        case .found:
//            NSLog("[AFSDK] Deep link found")
//        }
//
//        guard let deepLinkObj:DeepLink = result.deepLink else {
//            NSLog("[AFSDK] Could not extract deep link object")
//            return
//        }
//
//        if deepLinkObj.clickEvent.keys.contains("deep_link_sub2") {
//            let ReferrerId:String = deepLinkObj.clickEvent["deep_link_sub2"] as! String
//            NSLog("[AFSDK] AppsFlyer: Referrer ID: \(ReferrerId)")
//        } else {
//            NSLog("[AFSDK] Could not extract referrerId")
//        }
//
//        let deepLinkStr:String = deepLinkObj.toString()
//        NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
//
//        if( deepLinkObj.isDeferred == true) {
//            NSLog("[AFSDK] This is a deferred deep link")
//        }
//        else {
//            NSLog("[AFSDK] This is a direct deep link")
//        }
//
//        fruitNameStr = deepLinkObj.deeplinkValue
//        walkToSceneWithParams(fruitName: fruitNameStr!, deepLinkData: deepLinkObj.clickEvent)
//    }

     // For Swift version < 4.2 replace function signature with the commented out code

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
         let appsFlyerHandler = AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
         return appsFlyerHandler
     }
     
     // Open Deeplinks
     
     // Open URI-scheme for iOS 8 and below
     func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
         AppsFlyerLib.shared().handleOpen(url, sourceApplication: sourceApplication, withAnnotation: annotation)
         return true
     }

     // User logic
     fileprivate func walkToSceneWithParams(deepLinkObj: DeepLink) {
         let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
         
//        guard let fruitNameStr = deepLinkObj.clickEvent["deep_link_value"] as? String else {
//             print("Could not extract query params from link")
//             return
//         }
                
//         let destVC = fruitNameStr + "_vc"
//         if let newVC = storyBoard.instantiateVC(withIdentifier: destVC) {
//
//             print("AppsFlyer routing to section: \(destVC)")
//             newVC.deepLinkData = deepLinkObj
//
//              UIApplication.shared.windows.first?.rootViewController?.present(newVC, animated: true, completion: nil)
//         } else {
//             print("AppsFlyer: could not find section: \(destVC)")
//         }
     }
}
