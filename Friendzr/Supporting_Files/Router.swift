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
    
    func toSplach()  {
        let id = "SplachNC"
        let nextVC = Initializer.createViewController(storyBoard: .Splach, andId: id)
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
    
    func toMore()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UITabBarController else {return}
        nextVC.selectedIndex = 4
        go(withVC: nextVC)
    }
    
    func toEventsVC()  {
        let id = "EventsNC"
        let nextVC = Initializer.createViewController(storyBoard: .Events, andId: id)
        go(withVC: nextVC)
    }
    
    func toEditProfileVC() {
        let id = "EditMyProfileNC"
        let nextVC = Initializer.createViewController(storyBoard: .Profile, andId: id)
        go(withVC: nextVC)
    }
    
    func toMap()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UITabBarController else { return}
        nextVC.selectedIndex = 1
        go(withVC: nextVC)
    }
    
    func toResquests()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UITabBarController else {return}
        nextVC.selectedIndex = 3
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
