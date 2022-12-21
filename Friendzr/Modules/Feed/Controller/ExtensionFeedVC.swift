//
//  ExtensionFeedVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 20/12/2022.
//

import UIKit
import SwiftUI
import CoreLocation
import Contacts
import ListPlaceholder
import GoogleMobileAds
import SDWebImage
import Network
import AppTrackingTransparency
import AdSupport
import AMShimmer
import FirebaseAnalytics


extension FeedVC {
    
    func checkLocationPermission() {
        
        self.refreshControl.endRefreshing()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                //                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                Defaults.allowMyLocationSettings = false
                hideView.isHidden = true
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                switchCompassBarButton.isUserInteractionEnabled = false
                switchGhostModeBarButton.isUserInteractionEnabled = false
                self.switchSortedByInterestsButton.isUserInteractionEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                hideView.isHidden = true
                
                if !Defaults.isFirstOpenFeed {
                    showCompassExplainedView.isHidden = false
                    showPrivateModeExplainedView.isHidden = true
                    showSortByInterestsExplainedView.isHidden = true
                    
                    switchSortedByInterestsButton.isUserInteractionEnabled = false
                    switchCompassBarButton.isUserInteractionEnabled = false
                    switchGhostModeBarButton.isUserInteractionEnabled = false
                }else {
                    showCompassExplainedView.isHidden = true
                    showPrivateModeExplainedView.isHidden = true
                    showSortByInterestsExplainedView.isHidden = true
                    
                    switchSortedByInterestsButton.isUserInteractionEnabled = true
                    switchCompassBarButton.isUserInteractionEnabled = true
                    switchGhostModeBarButton.isUserInteractionEnabled = true
                }
                
                setupCompassContainerView()
                
                DispatchQueue.main.async {
                    self.updateUserInterface()
                }
                
                switchCompassBarButton.isUserInteractionEnabled = true
                switchGhostModeBarButton.isUserInteractionEnabled = true
                switchSortedByInterestsButton.isUserInteractionEnabled = true
                //                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            hideView.isHidden = true
            switchCompassBarButton.isUserInteractionEnabled = false
            switchGhostModeBarButton.isUserInteractionEnabled = false
            switchSortedByInterestsButton.isUserInteractionEnabled = false
            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            //            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
    
    //create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localizedString, style: .cancel)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString, comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func checkLocationPermissionBtns() {
        self.refreshControl.endRefreshing()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                Defaults.allowMyLocationSettings = false
                hideView.isHidden = true
                switchCompassBarButton.isUserInteractionEnabled = false
                switchGhostModeBarButton.isUserInteractionEnabled = false
                switchSortedByInterestsButton.isUserInteractionEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                hideView.isHidden = true
                switchCompassBarButton.isUserInteractionEnabled = true
                switchGhostModeBarButton.isUserInteractionEnabled = true
                switchSortedByInterestsButton.isUserInteractionEnabled = true
//                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            hideView.isHidden = true
            switchCompassBarButton.isUserInteractionEnabled = false
            switchGhostModeBarButton.isUserInteractionEnabled = false
            switchSortedByInterestsButton.isUserInteractionEnabled = false
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
}


extension FeedVC {
   // create Compass View
    func createCompassView() {
        if Defaults.isIPhoneLessThan2500 {
            let child = UIHostingController(rootView: CompassViewSwiftUIForIPhoneSmall())
            compassContanierView.addSubview(child.view)
            
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
            let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
            let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
            let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
            compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
        }else {
            let child = UIHostingController(rootView: CompassViewSwiftUIForIPhoneSmall2())
            compassContanierView.addSubview(child.view)
            
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
            let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
            let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
            let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
            compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }
    }

    //when deep link open compass to filter
    func deeplinkDirectionalFiltering() {
        if Defaults.isDeeplinkDirectionalFiltering {
            self.switchCompassBarButton.isOn = true
            self.isCompassOpen = true
            
            if Defaults.isSubscribe == false {
                DispatchQueue.main.async {
                    self.setupAds()
                }
                self.bannerViewHeight.constant = 50
            }
            else {
                self.bannerViewHeight.constant = 0
            }
            
            self.createLocationManager()
            self.filterDir = true
            self.filterBtn.isHidden = false
            self.compassContanierView.isHidden = false
            if Defaults.isIPhoneLessThan2500 {
                self.compassContainerViewHeight.constant = 200
            }else {
                self.compassContainerViewHeight.constant = 270
            }
            
            self.compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
            
            Defaults.isDeeplinkDirectionalFiltering = false
        }
    }
    
    //when isSubscribe is false show ads else hide ads
    func showandhideAds() {
        if Defaults.isSubscribe == false {
            requestIDFA()
            bannerViewHeight.constant = 50
        }else {
            bannerViewHeight.constant = 0
        }
    }
    func whenFirstOpenFeed() {
        if !Defaults.isFirstOpenFeed {
            self.firstOpenFees()
        }
        else {
            self.showCompassExplainedView.isHidden = true
            self.showPrivateModeExplainedView.isHidden = true
            self.showSortByInterestsExplainedView.isHidden = true
            self.switchSortedByInterestsButton.isUserInteractionEnabled = true
            self.switchCompassBarButton.isUserInteractionEnabled = true
            self.switchGhostModeBarButton.isUserInteractionEnabled = true
        }
    }
    func firstOpenFees() {
        if Defaults.token != "" {
            self.privateModelDialogueLbl.text = "Choose who you want to see and be seen by with Private Mode."
            self.compasslDialogueLbl.text = "Point your phone in any direction; Friendzrs are listed nearest first in that direction."
            self.sortDialogueLbl.text = "Toggle to sort your Friendzr feed by shared interests."
        }
        else {
            self.privateModelDialogueLbl.text = "You can filter the Feed by the groups you want to see (and be seen by)."
            self.compasslDialogueLbl.text = "You can sort the Feed by those nearest to you by pointing the phone in any direction."
            self.sortDialogueLbl.text = "You can sort the Feed by those who share your interests here."
        }
        
        self.showCompassExplainedView.isHidden = false
        self.showPrivateModeExplainedView.isHidden = true
        self.showSortByInterestsExplainedView.isHidden = true
        self.switchSortedByInterestsButton.isUserInteractionEnabled = false
        self.switchCompassBarButton.isUserInteractionEnabled = false
        self.switchGhostModeBarButton.isUserInteractionEnabled = false
    }
    func compassOpenOrClose() {
        if self.isCompassOpen {
            self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
        } else {
            if self.sortByInterestMatch {
                self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
            }else {
                self.LoadAllFeeds(pageNumber: 1)
            }
        }
    }
    
}
