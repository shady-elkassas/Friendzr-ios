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


class SplachVC: UIViewController , CLLocationManagerDelegate{
    
    var settingVM:SettingsViewModel = SettingsViewModel()
    var profileVM: ProfileViewModel = ProfileViewModel()
    
    var locationManager: CLLocationManager!
    var locationLat = 0.0
    var locationLng = 0.0
    var x = 0
    
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
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.7) {
            self.setupAnimation()
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5) {
            if Defaults.needUpdate == 1 {
                Router().toSplachOne()
            }else {
                if Defaults.token != "" {
                    Router().toFeed()
                }else {
                    Router().toOptionsSignUpVC()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Defaults.isFirstLaunch = true
    }
    
    func getProfileInformation() {
        self.showLoading()
        profileVM.getProfileInfo()
        profileVM.userModel.bind { [unowned self]value in
            self.hideLoading()
            DispatchQueue.main.async {
                Router().toFeed()
            }
        }
        
        // Set View Model Event Listener
        profileVM.error.bind { [unowned self]error in
            self.hideLoading()
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    var duration: Double = 1.5
    var delay: Double = 2.0
    var minimumBeats: Int = 1
    
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
    
    func setupCLLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        if Defaults.allowMyLocation == true {
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
                let placemark = placemarks![0]
                print(placemark.locality!)
                print(placemark.administrativeArea!)
                print(placemark.country!)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        self.checkLocationPermission()
    }
    
    
    func checkLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "Please enable location services to continue using the app".localizedString)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            default:
                break
            }
        } else {
            print("Location services are not enabled")
            createSettingsAlertController(title: "", message: "Please enable location services to continue using the app".localizedString)
        }
    }
    
    //    create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {_ in
            if Defaults.token != "" {
                self.settingVM.toggleAllowMyLocation(allowMyLocation: false) { error, data in
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    Defaults.allowMyLocation = data.allowmylocation ?? false
                }
            }
        })
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString, comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
