//
//  Router.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import Foundation
import UIKit

class Router {
    private func go(withVC vc:UIViewController) {
        let window = Initializer.getWindow()
        window.makeKeyAndVisible()
        window.rootViewController = vc
    }
    private func goPushInNavigationStack(withVC vc:UIViewController) {
        let window = Initializer.getWindow()
        window.makeKeyAndVisible()
        window.rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func go(WithNavigationController navVC:UINavigationController) {
        let window = Initializer.getWindow()
        window.makeKeyAndVisible()
        window.rootViewController = navVC
    }
    
    
    func toOptionsSignUpVC() {
        let id = "OptionsSignUpNC"
        let nextVC = Initializer.createViewController(storyBoard: .Register, andId: id)
        go(withVC: nextVC)
    }
    
    func toRegister() {
        let id = "RegisterNC"
        let nextVC = Initializer.createViewController(storyBoard: .Register, andId: id)
        go(withVC: nextVC)
    }
    
    func toLogin() {
        let id = "LoginNC"
        let nextVC = Initializer.createViewController(storyBoard: .Login, andId: id)
        go(withVC: nextVC)
    }
    
    func toHome()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UIViewController else { return}
        go(withVC: nextVC)
    }
    
    func toSplachOne()  {
        let id = "SplachOneNC"
        let nextVC = Initializer.createViewController(storyBoard: .Splach, andId: id)
        go(withVC: nextVC)
    }
    func toSplach2()  {
        let id = "SplachTwoNC"
        let nextVC = Initializer.createViewController(storyBoard: .Splach, andId: id)
        go(withVC: nextVC)
    }
    func toSplach3()  {
        let id = "SplachThreeNC"
        let nextVC = Initializer.createViewController(storyBoard: .Splach, andId: id)
        go(withVC: nextVC)
    }
    func toSplach4()  {
        let id = "SplachFourNC"
        let nextVC = Initializer.createViewController(storyBoard: .Splach, andId: id)
        go(withVC: nextVC)
    }
}

class HomeNC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
