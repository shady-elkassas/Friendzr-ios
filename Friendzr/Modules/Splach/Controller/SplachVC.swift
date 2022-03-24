//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/09/2021.
//

import UIKit
import CoreLocation
import SwiftUI


public typealias AnimationCompletion = () -> Void
public typealias AnimationExecution = () -> Void

//(ByLat: "\(51.509865)", AndLng: "\(-0.118092)") london

class SplachVC: UIViewController , CLLocationManagerDelegate, CAAnimationDelegate{
    
    var settingVM:SettingsViewModel = SettingsViewModel()
    var profileVM: ProfileViewModel = ProfileViewModel()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBar(NavigationBar: true, BackButton: true)
        setupCLLocationManager()
        
        let fistColor = UIColor.color("#7BE495")!
        let lastColor = UIColor.color("#329D9C")!
        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
        gradient.frame = view.frame
        view.layer.addSublayer(gradient)
        view.addSubview(imageView)
        
        initProfileBarButton()
        DispatchQueue.main.async {
            self.setupAnimation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachVC"
        print("availableVC >> \(Defaults.availableVC)")
        Defaults.isFirstLaunch = true
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
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
                Defaults.initValidationConfig(validate: value)
                DispatchQueue.main.async {
                    Router().toFeed()
                }
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
    

//    func animateMask() {
//        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
//        keyFrameAnimation.delegate = self
//        keyFrameAnimation.duration = 1
//        keyFrameAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
//        let initalBounds = NSValue(cgRect: mask!.bounds)
//        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 90, height: 90))
//        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1500, height: 1500))
//        keyFrameAnimation.values = [initalBounds, secondBounds, finalBounds]
//        keyFrameAnimation.keyTimes = [0, 0.3, 1]
//        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut), CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)]
//        self.mask!.add(keyFrameAnimation, forKey: "bounds")
//    }

//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        self.imageView.layer.mask = nil //remove mask when animation completes
//    }

    func setupAnimation() {
        UIView.animate(withDuration: 1) {
            let size = self.view.frame.size.width * 3
            let diffx = size - self.view.frame.size.width
            let diffy = self.view.frame.size.height - size
            
            self.imageView.frame = CGRect(x: -(diffx/2), y: diffy/2, width: size, height: size)
        }
        
        UIView.animate(withDuration: 1.5) {
            self.imageView.alpha = 0
            
            DispatchQueue.main.asyncAfter(wallDeadline: .now()) {
                if Defaults.needUpdate == 1 {
                    self.updateUserInterface()
                    
                    DispatchQueue.main.async {
                        Router().toSplachOne()
                    }
                }else {
                    if Defaults.token != "" {
                        self.updateUserInterface()
                    }else {
                        Router().toOptionsSignUpVC()
                    }
                }
            }
        }
    }
    
    func setupCLLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        if Defaults.allowMyLocationSettings == true {
            locationManager.startUpdatingLocation()
            
            //            if CLLocationManager.locationServicesEnabled(){
            //                locationManager.startUpdatingLocation()
            //            }
        }else {
            locationManager.stopUpdatingLocation()
            //            if CLLocationManager.locationServicesEnabled(){
            //                locationManager.stopUpdatingLocation()
            //            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        //        manager.stopUpdatingLocation()
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        self.locationLat = userLocation.coordinate.latitude
        self.locationLng = userLocation.coordinate.longitude
        Defaults.LocationLat = "\(self.locationLat)"
        Defaults.LocationLng = "\(self.locationLng)"
        
        print("Defaults.LocationLat : \(Defaults.LocationLat)","Defaults.LocationLng : \(Defaults.LocationLng)")
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }
            
            let placemark = (placemarks ?? []) as [CLPlacemark]
            if placemark.count>0{
                let placemark = placemarks?[0]
                print(placemark?.locality ?? "")
                print(placemark?.administrativeArea ?? "")
                print(placemark?.country ?? "")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        self.checkLocationPermission()
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
    
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            default:
                break
            }
        } else {
            print("Location services are not enabled")
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
    
    //    create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel".localizedString, comment: ""), style: .cancel, handler: {_ in
        })
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString.localizedString, comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
