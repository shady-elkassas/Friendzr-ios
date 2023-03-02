//
//  MainTBC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 25/01/2022.
//

import UIKit

class MainTBC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatebadgeRequests), name: Notification.Name("updatebadgeRequests"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatebadgeMore), name: Notification.Name("updatebadgeMore"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(updatebadgeInbox), name: Notification.Name("updatebadgeInbox"), object: nil)

        if Defaults.frindRequestNumber > 0 {
            self.tabBar.items![3].badgeValue = "\(Defaults.frindRequestNumber)"
            UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
        }else {
            Defaults.frindRequestNumber = 0
            self.tabBar.items![3].badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
        }
        
        if Defaults.notificationcount > 0 {
            self.tabBar.items![4].badgeValue = "\(Defaults.notificationcount)"
            UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
        }else {
            Defaults.notificationcount = 0
            self.tabBar.items![4].badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
        }
        
        if Defaults.message_Count > 0 {
            self.tabBar.items![0].badgeValue = "\(Defaults.message_Count)"
            UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
        }else {
            Defaults.message_Count = 0
            self.tabBar.items![0].badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
        }
    }
    
    @objc func updatebadgeRequests() {
        if Defaults.frindRequestNumber > 0 {
            self.tabBar.items![3].badgeValue = "\(Defaults.frindRequestNumber)"
        }else {
            Defaults.frindRequestNumber = 0
            self.tabBar.items![3].badgeValue = nil
        }

        NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
        UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
    }
    
    @objc func updatebadgeMore() {
        if Defaults.notificationcount > 0 {
            self.tabBar.items![4].badgeValue = "\(Defaults.notificationcount)"
        }else {
            Defaults.notificationcount = 0
            self.tabBar.items![4].badgeValue = nil
        }
        
        UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
    }
    
    @objc func updatebadgeInbox() {
        if Defaults.message_Count > 0 {
            self.tabBar.items![0].badgeValue = "\(Defaults.message_Count)"
        }else {
            Defaults.message_Count = 0
            self.tabBar.items![0].badgeValue = nil
        }
        
        UIApplication.shared.applicationIconBadgeNumber = Defaults.message_Count + Defaults.notificationcount + Defaults.frindRequestNumber
    }
}


