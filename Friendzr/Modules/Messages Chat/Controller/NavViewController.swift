//
//  NavViewController.swift
//  Friendzr
//
//  Created by Shady Elkassas on 24/05/2022.
//

import UIKit

class NavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        self.navigationBar.isTranslucent = true
        self.navigationBar.barTintColor = UIColor.setColor(lightColor: .white, darkColor: .black)
        self.navigationBar.shadowImage = UIColor.black.as1ptImage()
        self.navigationBar.setBackgroundImage(UIColor.white.as1ptImage(), for: .default)
        self.navigationBar.backgroundColor = .white
        self.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        self.view.backgroundColor = .white
        self.navigationBar.layoutIfNeeded()
        
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: UITextView.textDidBeginEditingNotification, object: nil, userInfo: nil)
    }

}
