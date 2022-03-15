//
//  NavController.swift
//  Friendzr
//
//  Created by Shady Elkassas on 15/03/2022.
//

import UIKit

class NavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 14) ?? "",NSAttributedString.Key.foregroundColor: UIColor.setColor(lightColor: UIColor.color("#241332")!, darkColor: .white)]
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = UIColor.setColor(lightColor: .white, darkColor: .black)
        navigationController?.navigationBar.setBackgroundImage(UIImage() , for:UIBarMetrics.default)
        navigationController?.navigationBar.backgroundColor = .white
        view.backgroundColor = .white
    }
}
