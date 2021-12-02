//
//  ExtensionMessagesViewController.swift
//  Friendzr
//
//  Created by Shady Elkassas on 01/12/2021.
//

import UIKit
import MessageKit


extension MessagesViewController {
    
    func setupNavigationbar() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        view.backgroundColor = UIColor.FriendzrColors.primary
    }
}
