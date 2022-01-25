//
//  MainTBC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 25/01/2022.
//

import UIKit

class MainTBC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatebadgeRequests), name: Notification.Name("updatebadgeRequests"), object: nil)
        
        if BadgeRequestsCount.count != 0 {
            self.tabBar.items![3].badgeValue = "\(BadgeRequestsCount.count)"
        }else {
            self.tabBar.items![3].badgeValue = nil
        }
    }
    
    @objc func updatebadgeRequests() {
        
        if BadgeRequestsCount.count != 0 {
            self.tabBar.items![3].badgeValue = "\(BadgeRequestsCount.count)"
        }else {
            self.tabBar.items![3].badgeValue = nil
        }
    }
}
