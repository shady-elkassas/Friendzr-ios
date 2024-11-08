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
    
    func toOptionsSignUpVC(IsLogout:Bool) {
        let id = "OptionsSignUpNC"
        let nextVC = Initializer.createViewController(storyBoard: .Register, andId: id)
        
//        if !IsLogout {
//            nextVC.view.makeToast("To enjoy these features, you must log in first.")
//        }
        go(withVC: nextVC)
    }
    
    func toWelcomeVC() {
        let id = "LandingPageNC"
        let nextVC = Initializer.createViewController(storyBoard: .Splach, andId: id)
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
    
    func toSplach5()  {
        let id = "SplachFiveNC"
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
            
            Defaults.isFirstLogin = true
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
    
    func toInbox()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UITabBarController else {return}
        nextVC.selectedIndex = 0
        go(withVC: nextVC)
    }
    
    func toFeed()  {
        let id = "MainTBC"
        guard let nextVC = Initializer.createViewController(storyBoard: .Main, andId: id) as? UITabBarController else { return}
        nextVC.selectedIndex = 2
        go(withVC: nextVC)
    }
    
    func toConversationVC(isEvent:Bool,eventChatID:String,leavevent:Int,chatuserID:String,isFriend:Bool,titleChatImage:String,titleChatName:String,isChatGroupAdmin:Bool,isChatGroup:Bool,groupId:String,leaveGroup:Int,isEventAdmin:Bool) {
        if let controller = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesNC") as? UINavigationController, let vc = controller.viewControllers.first as? MessagesVC {
            if isEvent == true {
                vc.isEvent = true
                vc.eventChatID = eventChatID
                vc.chatuserID = ""
                vc.leavevent = leavevent
                vc.leaveGroup = 1
                vc.isFriend = false
                vc.isChatGroupAdmin = false
                vc.isChatGroup = false
                vc.groupId = ""
                vc.isEventAdmin = isEventAdmin
            }else {
                if isChatGroup == true {
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = ""
                    vc.leavevent = 1
                    vc.leaveGroup = leaveGroup
                    vc.isFriend = false
                    vc.isChatGroupAdmin = isChatGroupAdmin
                    vc.isChatGroup = isChatGroup
                    vc.groupId = groupId
                    vc.isEventAdmin = false
                }else {
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = chatuserID
                    vc.leaveGroup = 1
                    vc.isFriend = isFriend
                    vc.leavevent = leavevent
                    vc.isChatGroupAdmin = false
                    vc.isChatGroup = false
                    vc.groupId = ""
                    vc.isEventAdmin = false
                }
            }
            
            vc.titleChatImage = titleChatImage
            vc.titleChatName = titleChatName
            CancelRequest.currentTask = false
            go(withVC: controller)
        }
    }
    
    func toReportVC(id:String,reportType:Int,chatimg:String,chatname:String)  {
        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
            vc.id = id
            vc.chatimg = chatimg
            vc.chatname = chatname
            vc.reportType = reportType
            go(withVC: controller)
        }
    }
//    func toGroupVC(groupId:String,isGroupAdmin:Bool)  {
//        if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "GroupDetailsNC") as? UINavigationController, let vc = controller.viewControllers.first as? GroupDetailsVC {
//            vc.groupId = groupId
//            vc.isGroupAdmin = isGroupAdmin
//            go(withVC: controller)
//        }
//    }
    
    func toEventDetailsVC(eventId:String,isConv:Bool,isEventAdmin:Bool)  {
        if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsNavC") as? UINavigationController, let vc = controller.viewControllers.first as? EventDetailsViewController {
            vc.eventId = eventId
            vc.isConv = isConv
            vc.isEventAdmin = isEventAdmin
            go(withVC: controller)
        }
    }
    
    func toSTutorialScreensOneVC()  {
        let id = "TutorialScreensOneNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
        go(withVC: nextVC)
    }
    func toSTutorialScreensTwoVC()  {
        let id = "TutorialScreensTwoNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
        go(withVC: nextVC)
    }
    func toSTutorialScreensThreeVC()  {
        let id = "TutorialScreensThreeNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
        go(withVC: nextVC)
    }
    func toSTutorialScreensFourVC()  {
        let id = "TutorialScreensFourNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
        go(withVC: nextVC)
    }
    func toSTutorialScreensFiveVC()  {
        let id = "TutorialScreensFiveNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
        go(withVC: nextVC)
    }
    func toSTutorialScreensSixVC()  {
        let id = "TutorialScreensSixNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
        go(withVC: nextVC)
    }
    
    func toSTutorialScreensSevenVC()  {
        let id = "TutorialScreensSevenNC"
        let nextVC = Initializer.createViewController(storyBoard: .TutorialScreens, andId: id)
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
