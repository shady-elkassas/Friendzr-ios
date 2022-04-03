//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/09/2021.
//

import UIKit
import CoreLocation
import SwiftUI
import RevealingSplashView

public typealias AnimationCompletion = () -> Void
public typealias AnimationExecution = () -> Void

//(ByLat: "\(51.509865)", AndLng: "\(-0.118092)") london

class SplachVC: UIViewController , CLLocationManagerDelegate, CAAnimationDelegate{
    
    var settingVM:SettingsViewModel = SettingsViewModel()
    var profileVM: ProfileViewModel = ProfileViewModel()
    var allValidatConfigVM:AllValidatConfigViewModel = AllValidatConfigViewModel()
    
    var locationManager: CLLocationManager!
    var locationLat = 0.0
    var locationLng = 0.0
    
    var duration: Double = 1.5
    var delay: Double = 2.0
    var minimumBeats: Int = 1
    
    var internetConect:Bool = false
    var mask: CALayer? = CALayer()
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: 70 , height: 70)
        image.center = view.center
        image.image = UIImage(named: "splashImg")
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .clear
        return image
    }()
    
    private var revealingLoaded = false
    
    override var shouldAutorotate: Bool {
        return revealingLoaded
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return !UIApplication.shared.isStatusBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        hideNavigationBar(NavigationBar: true, BackButton: true)
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "splashImg")!, iconInitialSize: CGSize(width: 70, height: 70), backgroundColor: .clear)
        
        
        self.view.addSubview(revealingSplashView)
        
        revealingSplashView.duration = 1.5
        
        revealingSplashView.iconColor = UIColor.red
        revealingSplashView.useCustomIconColor = false
        
        revealingSplashView.animationType = SplashAnimationType.twitter
        
        revealingSplashView.startAnimation(){
            self.revealingLoaded = true
            self.setNeedsStatusBarAppearanceUpdate()
            print("Completed")
            
            DispatchQueue.main.asyncAfter(wallDeadline: .now()) {
                if Defaults.needUpdate == 1 {
                    DispatchQueue.main.async {
                        Router().toSplachOne()
                    }
                }else {
                    if Defaults.token != "" {
                        Router().toFeed()
                    }else {
                        Router().toOptionsSignUpVC()
                    }
                }
            }
        }
        
        initProfileBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachVC"
        print("availableVC >> \(Defaults.availableVC)")
        Defaults.isFirstLaunch = true
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CancelRequest.currentTask = true
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            getAllValidatConfig()
        case .wifi:
            internetConect = true
            getAllValidatConfig()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func getAllValidatConfig() {
        allValidatConfigVM.getAllValidatConfig()
        allValidatConfigVM.userValidationConfig.bind { [unowned self]value in
            DispatchQueue.main.async {
                Router().toFeed()
            }
        }
        
        // Set View Model Event Listener
        allValidatConfigVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func animateLayer(_ animation: AnimationExecution, completion: AnimationCompletion? = nil) {
        
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock { completion() }
        }
        animation()
        CATransaction.commit()
    }
    
    func setupAnimation() {
        UIView.animate(withDuration: 1) {
            let size = self.view.frame.size.width * 3
            let diffx = size - self.view.frame.size.width
            let diffy = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(x: -(diffx/2), y: diffy/2, width: size, height: size)
        }
        
        UIView.animate(withDuration: 1.5) {
            self.imageView.alpha = 0
            
            
        }
    }
    
    func HandleInternetConnection() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
            if Defaults.needUpdate == 1 {
                DispatchQueue.main.async {
                    Router().toSplachOne()
                }
            }else {
                if Defaults.token != "" {
                    Router().toFeed()
                }else {
                    Router().toOptionsSignUpVC()
                }
            }
        }
    }
}
