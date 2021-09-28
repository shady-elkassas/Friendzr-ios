//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/09/2021.
//

import UIKit
import CoreLocation

class SplachVC: UIViewController , CLLocationManagerDelegate{
    
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    
    var locationManager: CLLocationManager!
    var locationLat = 0.0
    var locationLng = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBar(NavigationBar: true, BackButton: true)
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5) {
            if Defaults.needUpdate == 1 {
                Router().toEditProfileVC()
            }else {
                if Defaults.token != "" {
                    Router().toHome()
                }else {
                    Router().toSplachOne()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupCLLocationManager()
    }
    
    func updateMyLocation() {
        updateLocationVM.updatelocation(ByLat: self.locationLat, AndLng: self.locationLng) { error, data in
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let _ = data else {return}
        }
    }
    
    
    func setupCLLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if Defaults.allowMyLocation {
            if CLLocationManager.locationServicesEnabled(){
                locationManager.startUpdatingLocation()
            }
        }else {
            if CLLocationManager.locationServicesEnabled(){
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        self.locationLat = userLocation.coordinate.latitude
        self.locationLng = userLocation.coordinate.longitude
        Defaults.LocationLat = "\(self.locationLat )"
        Defaults.LocationLng = "\(self.locationLng )"
        
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.updateMyLocation()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        //        self.checkLocationPermission()
    }
}
