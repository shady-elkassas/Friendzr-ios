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
    
    func toEditProfileVC(needUpdate:Bool) {
        if let controller = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileNC") as? UINavigationController, let vc = controller.viewControllers.first as? EditMyProfileVC {
            if needUpdate == true {
                vc.needUpdateVC = true
            }else {
                vc.needUpdateVC = false
            }
            go(withVC: controller)
        }
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
    
    func toFeed()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UITabBarController else { return}
        nextVC.selectedIndex = 2
        go(withVC: nextVC)
    }
    
    func toConversationVC(isEvent:Bool,eventChatID:String,leavevent:Int,chatuserID:String,isFriend:Bool,titleChatImage:String,titleChatName:String) {
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ConversationNC") as? UINavigationController, let vc = controller.viewControllers.first as? ConversationVC {
            if isEvent == true {
                vc.isEvent = true
                vc.eventChatID = eventChatID
                vc.chatuserID = ""
                vc.leavevent = leavevent
            }else {
                vc.isEvent = false
                vc.eventChatID = ""
                vc.chatuserID = chatuserID
                vc.isFriend = isFriend
            }
            
            vc.titleChatImage = titleChatImage
            vc.titleChatName = titleChatName
            CancelRequest.currentTask = false
            go(withVC: controller)
        }
    }
    
    func toReportVC()  {
        let id = "ReportNC"
        let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id)
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
