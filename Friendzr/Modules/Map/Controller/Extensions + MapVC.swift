//
//  Extensions + MapVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/12/2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import ObjectMapper
import MapKit
import GoogleMobileAds
import ListPlaceholder
import Network
import SDWebImage

extension MapVC {
    func setupDatePickerForStartDate(){
        //Formate Date
        
        endDateTxt.isUserInteractionEnabled = false
        datePicker1.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker1.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePicker1.minimumDate = Date()
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker1))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        startDateTxt.inputAccessoryView = toolbar
        startDateTxt.inputView = datePicker1
        
    }
    @objc func donedatePicker1(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        startDateTxt.text = formatter.string(from: datePicker1.date)
        self.startDate = formatter.string(from: self.datePicker1.date)
        
        var comps2:DateComponents = DateComponents()
        comps2.year = 10
        comps2.month = 1
        comps2.day = -1
        
        self.minimumDate = (self.datePicker1.date)
        self.maximumDate = self.datePicker1.calendar.date(byAdding: comps2, to: self.minimumDate)!
        
        print(formatter.string(from: self.minimumDate),formatter.string(from: self.maximumDate))
        
        endDateTxt.isUserInteractionEnabled = true
        setupDatePickerForEndDate()
        self.view.endEditing(true)
    }
    
    func setupDatePickerForEndDate(){
        //Formate Date
        datePicker2.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker2.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePicker2.minimumDate = self.minimumDate
        datePicker2.maximumDate = self.maximumDate
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker2))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))
        
        doneButton.tintColor = UIColor.FriendzrColors.primary!
        cancelButton.tintColor = UIColor.red
        
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        endDateTxt.inputAccessoryView = toolbar
        endDateTxt.inputView = datePicker2
        
    }
    
    @objc func donedatePicker2(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        endDateTxt.text = formatter.string(from: datePicker2.date)
        self.endDate = formatter.string(from: datePicker2.date)
        
        self.view.endEditing(true)
    }


    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
}

//MARK: check Location Permission
extension MapVC {
    func checkLocationPermission() {
        
        if !Defaults.isFirstOpenMap {
            if Defaults.token != "" {
                nearByEventsDialogueLbl.text = "You can browse a list of events nearest to you here."
                filterDialogueLbl.text = "Click to set and display events from your preferred interest categories."
                addEventDialogueLbl.text = "To create an event, click on “+” to select a location on the map for your event then click “+” again to confirm location."
            }else {
                nearByEventsDialogueLbl.text = "You can browse a list of events nearest to you here."
                filterDialogueLbl.text = "You can sort filter events by your interests here."
                addEventDialogueLbl.text = "You can add your own event to the map here – inviting your connections or opening to all Friendzrs."
            }
            
            showFilterExplainedView.isHidden = false
            switchFilterButton.isUserInteractionEnabled = false
            sataliteBtn.isUserInteractionEnabled = false
            currentLocationBtn.isUserInteractionEnabled = false
        }else {
            showFilterExplainedView.isHidden = true
            switchFilterButton.isUserInteractionEnabled = true
            addEventBtn.isUserInteractionEnabled = true
            sataliteBtn.isUserInteractionEnabled = true
            currentLocationBtn.isUserInteractionEnabled = true
            goAddEventBtn.isUserInteractionEnabled = true
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                self.createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
                self.upDownBtn.isUserInteractionEnabled = false
                self.isViewUp = false
                self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                Defaults.allowMyLocationSettings = false
                self.removeGestureSwipeSubView()
                NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
                locationManager.stopUpdatingLocation()
                self.zoomingStatisticsView.isHidden = true
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.updateUserInterface()
                }
                
                locationManager.showsBackgroundLocationIndicator = false
                locationManager.stopUpdatingLocation()
                
                DispatchQueue.main.async {
                    self.isViewUp = false
                    self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                    self.upDownBtn.isUserInteractionEnabled = true
                    self.setupSwipeSubView()
                    self.zoomingStatisticsView.isHidden = false
                }
            default:
                break
            }
        }else {
            print("Location services are not enabled")
            self.upDownBtn.isUserInteractionEnabled = false
            self.isViewUp = false
            self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            Defaults.allowMyLocationSettings = false
            self.removeGestureSwipeSubView()
            self.zoomingStatisticsView.isHidden = true
            
            self.createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
        }
        
    }
    
    func checkLocationPermissionBtns() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                self.createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
                Defaults.allowMyLocationSettings = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.showsBackgroundLocationIndicator = false
                Defaults.allowMyLocationSettings = true
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            self.createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
        }
    }
    
}

//MARK: check Deep Link Direction
extension MapVC {
    
    func setCatIds() {
        catIDs = Defaults.catIDs
        
        for cat in Defaults.catIDs {
            for item in Defaults.catSelectedNames {
                catSelectedArr.append(CategoryObj(id: cat, name: item, isSelected: true))
            }
        }
        
        catSelectedNames = Defaults.catSelectedNames
        dateTypeSelected = Defaults.dateTypeSelected
    }
    
    func checkDeepLinkDirection() {
        if self.checkoutName == "eventFilter" {
            self.handleFilterByCategorySwitchBtn()
            self.checkoutName = ""
        }
        else if self.checkoutName == "createEvent" {
            self.checkLocationPermission()
            self.appendNewLocation = true
            self.view.makeToast("Please pick event's location".localizedString)
            self.goAddEventBtn.isHidden = false
            self.addEventBtn.isHidden = true
            self.markerImg.isHidden = false
            self.checkoutName = ""
            Defaults.availableVC = ""
        }
        else {
            appendNewLocation = false
            goAddEventBtn.isHidden = true
            addEventBtn.isHidden = false
            markerImg.isHidden = true
        }
    }
}


//MARK: - Random Between Numbers locations
extension MapVC {
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func generateLocs() {
        
        var num = 0
        pepoleLocations.removeAll()
        
        while num != 3000 {
            num += 1
            
            let locCLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(randomBetweenNumbers(firstNum: 50.076452, secondNum: 52.529640)), longitude: CLLocationDegrees(randomBetweenNumbers(firstNum: -5.706604, secondNum: 1.732969)))
            
            pepoleLocations.append(locCLLocationCoordinate2D)
        }
    }
}


//MARK: - GADBannerViewDelegate
extension MapVC:GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        //        addBannerViewToView(bannerView2)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerViewHeight.constant = 0
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}


//MARK: - initFilterBarButton
extension MapVC {
    func initFilterBarButton() {
        switchFilterButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        switchFilterButton.onTintColor = UIColor.FriendzrColors.primary!
        switchFilterButton.setBorder()
        switchFilterButton.offTintColor = UIColor.white
        switchFilterButton.cornerRadius = 0.5
        switchFilterButton.thumbCornerRadius = 0.5
        switchFilterButton.animationDuration = 0.25
        
        if Defaults.catIDs.count != 0 {
            switchFilterButton.isOn = true
            switchFilterButton.thumbImage = UIImage(named: "filterMap_on_ic")
        }
        else if Defaults.dateTypeSelected != "" {
            switchFilterButton.isOn = true
            switchFilterButton.thumbImage = UIImage(named: "filterMap_on_ic")
        }
        else {
            switchFilterButton.isOn = false
            switchFilterButton.thumbImage = UIImage(named: "filterMap_on_ic")
        }
        
        switchFilterButton.addTarget(self, action:  #selector(handleFilterSwitchBtn), for: .touchUpInside)
        
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .up))
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .down))
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .left))
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .right))
        let barButton = UIBarButtonItem(customView: switchFilterButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func didFilterSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        switch sender.direction {
        case .up:
            break
        case .down:
            break
        case .left:
            handleFilterByCategorySwitchBtn()
        case .right:
            handleFilterByCategorySwitchBtn()
        default:
            break
        }
        
        print("\(switchFilterButton.isOn)")
    }
    
    @objc func handleFilterSwitchBtn() {
        if (catsviewmodel.cats.value?.count ?? 0) != 0 {
            handleFilterByCategorySwitchBtn()
        }
        else {
            initFilterBarButton()
            return
        }
    }
    
    func handleFilterByCategorySwitchBtn() {
        if NetworkConected.internetConect {
            if Defaults.catIDs.count == 0 && Defaults.dateTypeSelected == "" {
                switchFilterButton.isUserInteractionEnabled = false
                self.catsSuperView.isHidden = false
            }
            else {
                self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.showAlertView?.editBtn.isHidden = false
                
                self.showAlertView?.titleLbl.text = "Confirm?".localizedString
                self.showAlertView?.detailsLbl.text = "Are you sure you want to turn off filters or change the settings?".localizedString
                
                DispatchQueue.main.async {
                    self.switchFilterButton.isUserInteractionEnabled = false
                }
                
                self.showAlertView?.HandleOffBtn = {
                    if NetworkConected.internetConect {
                        
                        self.catIDs.removeAll()
                        self.catSelectedNames.removeAll()
                        self.catSelectedArr.removeAll()
                        Defaults.catIDs.removeAll()
                        Defaults.dateTypeSelected = ""
                        self.dateTypeSelected = ""
                        Defaults.catSelectedNames.removeAll()
                        
                        self.setupFilterDateViews(didselect: "")
                        
                        DispatchQueue.main.async {
                            DispatchQueue.main.async {
                                self.mapView.clear()
                                self.locationsModel.peoplocationDataMV?.removeAll()
                                self.locationsModel.eventlocationDataMV?.removeAll()
                                self.locations.removeAll()
                                self.pepoleLocations.removeAll()
                            }
                            
                            DispatchQueue.main.async {
                                if Defaults.token != "" {
                                    self.updateLocation()
                                }
                                
                                self.setupGoogleMap(zoom1: 8, zoom2: 14)
                            }
                            
                            DispatchQueue.main.async {
                                self.collectionViewHeight.constant = 0
                                self.noeventNearbyLbl.isHidden = true
                                self.subViewHeight.constant = 50
                                self.subView.isHidden = false
                                self.isViewUp = false
                                self.hideCollectionView.isHidden = true
                                self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                            }
                            
                            DispatchQueue.main.async {
                                self.checkLocationPermission()
                            }
                            
                            DispatchQueue.main.async {
                                self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
                            }
                        }
                    }
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
                            self.switchFilterButton.isUserInteractionEnabled = true
                        }
                        
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.showAlertView?.HandleHideViewBtn = {
                    DispatchQueue.main.async {
                        self.initFilterBarButton()
                        self.switchFilterButton.isUserInteractionEnabled = true
                    }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.showAlertView?.HandleEditBtn = {
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                    
                    self.initFilterBarButton()
                    self.switchFilterButton.isUserInteractionEnabled = false
                    self.catsSuperView.isHidden = false
                    
                }
                
                self.view.addSubview((self.showAlertView)!)
            }
        }
        else {
            HandleInternetConnection()
            if Defaults.catIDs.count != 0 || Defaults.dateTypeSelected != "" {
                switchFilterButton.isOn = true
            }else {
                switchFilterButton.isOn = false
            }
        }
        
        initFilterBarButton()
    }
    
    func createFilterSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didFilterSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    //MARK: - Actions
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        let frame = subView.frame
        
        switch sender.direction {
        case .up:
            if NetworkConected.internetConect{
                print("Up")
                if Defaults.allowMyLocationSettings {
                    collectionViewHeight.constant = 140
                    subViewHeight.constant = 190
                    subView.isHidden = false
                    isViewUp = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-down_ic")
                    
                    DispatchQueue.main.async {
                        //                        self.currentPage = 1
                        self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
                    }
                }
                else {
                    collectionViewHeight.constant = 0
                    self.noeventNearbyLbl.isHidden = true
                    subViewHeight.constant = 50
                    subView.isHidden = false
                    isViewUp = false
                    self.hideCollectionView.isHidden = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                    
                    createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
                }
            }else {
                HandleInternetConnection()
            }
        case .down:
            if NetworkConected.internetConect {
                print("Down")
                collectionViewHeight.constant = 0
                self.hideCollectionView.isHidden = true
                self.noeventNearbyLbl.isHidden = true
                subViewHeight.constant = 50
                subView.isHidden = false
                isViewUp = false
                arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            }else {
                HandleInternetConnection()
            }
        case .left: break
        case .right: break
        default:
            break
        }
        
        UIView.animate(withDuration: 0.25) {
            self.subView.frame = frame
        }
        
        print("x:\(frame.origin.x),y:\(frame.origin.y)")
    }
    
    //MARK: - Helper Methods
    func createSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    func onFilterByCatsCallBack(_ listIDs: [String],_ listNames: [String],_ selectCats:[CategoryObj]) -> () {
        
        catIDs = listIDs
        catSelectedNames = listNames
        catSelectedArr = selectCats
        
        DispatchQueue.main.async {
            Defaults.catSelectedNames = listNames
            Defaults.catIDs = listIDs
        }

        Defaults.dateTypeSelected = dateTypeSelected
        
        print("catIDs = \(catIDs) && \(dateTypeSelected)")
        
        
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
        
        DispatchQueue.main.async {
            
            DispatchQueue.main.async {
                self.mapView.clear()
                self.locationsModel.peoplocationDataMV?.removeAll()
                self.locationsModel.eventlocationDataMV?.removeAll()
                self.locations.removeAll()
                self.pepoleLocations.removeAll()
            }
            
            DispatchQueue.main.async {
                if Defaults.token != "" {
                    self.updateLocation()
                }
                self.setupGoogleMap(zoom1: 8, zoom2: 14)
            }
            
            DispatchQueue.main.async {
                self.collectionViewHeight.constant = 0
                self.noeventNearbyLbl.isHidden = true
                self.subViewHeight.constant = 50
                self.subView.isHidden = false
                self.isViewUp = false
                self.hideCollectionView.isHidden = true
                self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            }
            
            DispatchQueue.main.async {
                self.checkLocationPermission()
            }
            
            DispatchQueue.main.async {
                //                self.currentPage = 1
                self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
            }
        }
    }
    
}

//MARK: - Events Only Around Me
extension MapVC {
    func handleShowEventsSubView(value:EventsOnlyAroundMeModel) {
        if self.isViewUp == true {
            self.collectionViewHeight.constant = 140
            self.subViewHeight.constant = 190
            
            if value.data?.count == 0 {
                self.noeventNearbyLbl.isHidden = false
                if self.switchFilterButton.isOn == true {
                    self.noeventNearbyLbl.text = "No events as yet in your chosen categories. Adjust your settings or check back later."
                }else {
                    self.noeventNearbyLbl.text = "No events as yet."
                }
            }else {
                self.noeventNearbyLbl.isHidden = true
            }
        }else {
            self.collectionViewHeight.constant = 0
            self.subViewHeight.constant = 50
            self.noeventNearbyLbl.isHidden = true
            self.hideCollectionView.isHidden = true
        }
    }
}
