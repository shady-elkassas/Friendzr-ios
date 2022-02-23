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
        
        if Defaults.frindRequestNumber != 0 {
            self.tabBar.items![3].badgeValue = "\(Defaults.frindRequestNumber)"
        }else {
            self.tabBar.items![3].badgeValue = nil
        }
        
//        if Defaults.messagesInboxCountBadge != 0 {
//            self.tabBar.items![0].badgeValue = "\(Defaults.messagesInboxCountBadge)"
//        }else {
//            self.tabBar.items![0].badgeValue = "0"
//        }
    }
    
    @objc func updatebadgeRequests() {
        if Defaults.frindRequestNumber != 0 {
            self.tabBar.items![3].badgeValue = "\(Defaults.frindRequestNumber)"
        }else {
            self.tabBar.items![3].badgeValue = nil
        }
        NotificationCenter.default.post(name: Notification.Name("updateMoreTableView"), object: nil, userInfo: nil)
    }
    
//    @objc func updatebadgeInbox() {
//        
//        if Defaults.frindRequestNumber != 0 {
//            self.tabBar.items![0].badgeValue = "\(Defaults.messagesInboxCountBadge)"
//        }else {
//            self.tabBar.items![0].badgeValue = nil
//        }
//    }
}
