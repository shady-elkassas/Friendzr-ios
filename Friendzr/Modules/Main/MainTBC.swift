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
        
        if Defaults.frindRequestNumber != 0 {
            self.tabBar.items![3].badgeValue = "\(Defaults.frindRequestNumber)"
        }else {
            self.tabBar.items![3].badgeValue = nil
        }
        
        if Defaults.notificationcount != 0 {
            self.tabBar.items![4].badgeValue = "\(Defaults.notificationcount)"
        }else {
            self.tabBar.items![4].badgeValue = nil
        }
    }
    
    @objc func updatebadgeRequests() {
        if Defaults.frindRequestNumber != 0 {
            self.tabBar.items![3].badgeValue = "\(Defaults.frindRequestNumber)"
        }else {
            self.tabBar.items![3].badgeValue = nil
        }
        
        NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
    }
    
    @objc func updatebadgeMore() {
        if Defaults.notificationcount != 0 {
            self.tabBar.items![4].badgeValue = "\(Defaults.notificationcount)"
        }else {
            self.tabBar.items![4].badgeValue = nil
        }
    }
    
}
