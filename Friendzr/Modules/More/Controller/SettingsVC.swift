//
//  SettingsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 26/10/2021.
//

import UIKit
import CoreLocation
import SwiftUI
import MultiSlider
import ListPlaceholder

class SettingsVC: UIViewController {
    
    @IBOutlet weak var settingSubView: UIView!
    @IBOutlet weak var settingsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var ageSliderView: UIView!
    @IBOutlet weak var ageSliderBtn: UIButton!
    @IBOutlet weak var ageSlider: MultiSlider!
    @IBOutlet weak var distanceSliderView: UIView!
    @IBOutlet weak var distanceSliderBtn: UIButton!
    @IBOutlet weak var distanceSlider: MultiSlider!
    @IBOutlet weak var manualDistanceLbl: UILabel!
    @IBOutlet weak var ageFromLbl: UILabel!
    @IBOutlet weak var ageToLbl: UILabel!
    @IBOutlet weak var hideView: UIView!
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("HideGhostModeView", owner: self, options: nil)?.first as? HideGhostModeView
    
    lazy var deleteAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var viewmodel:SettingsViewModel = SettingsViewModel()
    var allowmylocationtype:Int = 0
    var model:SettingsObj? = nil
    
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    
    var locationManager: CLLocationManager!
    var locationLat = 0.0
    var locationLng = 0.0
    
    let screenSize = UIScreen.main.bounds.size
    
    var internetConect:Bool = false
    
    var ageFrom:Int = 14
    var ageTo:Int = 85
    var manualdistancecontrol:Double = 0.2
    
    let settingCellID = "SettingsTableViewCell"
    let deleteCllID = "DeleteAccountTableViewCell"
    var ghostmode:String = ""

    var isAgeFilterAvailable:Bool = false
    var isDistanceFilterAvailable:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupView()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        transparentView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: Notification.Name("updateSettings"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SettingsVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        initBackButton()
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
        self.title = "Settings".localizedString

        setupCLLocationManager()
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    @objc func updateSettings() {
        DispatchQueue.main.async {
            self.getUserSettings()
        }
    }
    
    //MARK:- APIs
    func getUserSettings() {
        viewmodel.getUserSetting()
        viewmodel.userSettings.bind { [unowned self]value in
            DispatchQueue.main.async {
                self.hideView.isHidden = true
                self.model = value
                self.setupData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                print(error)
            }
        }
    }
        
    func setupData() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        settingsViewHeight.constant = CGFloat(8 * 50)
        Defaults.myAppearanceTypes = model?.myAppearanceTypes ?? []
        Defaults.ghostMode = model?.ghostmode ?? false
        Defaults.pushnotification = model?.pushnotification ?? false
        
        ageFrom = model?.agefrom ?? 14
        ageTo = model?.ageto ?? 85
        manualdistancecontrol = (model?.manualdistancecontrol ?? 0.2)
        
        isDistanceFilterAvailable = model?.distanceFilter ?? false
        isAgeFilterAvailable = model?.filteringaccordingtoage ?? false
        
        DispatchQueue.main.async { [self] in
            if self.model?.ghostmode == true {
                if self.model?.myAppearanceTypes == [1] {
                    Defaults.ghostModeEveryOne = true
                }else {
                    Defaults.ghostModeEveryOne = false
                }
            }else {
                Defaults.ghostModeEveryOne = false
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            getUserSettings()
        case .wifi:
            internetConect = true
            getUserSettings()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func updateUserInterfaceForBtns() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
        case .wifi:
            internetConect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    func updateMyLocation() {
        updateLocationVM.updatelocation(ByLat: Defaults.LocationLat, AndLng: Defaults.LocationLng) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
        }
    }
    
    func setupView() {
        tableView.register(UINib(nibName: settingCellID, bundle: nil), forCellReuseIdentifier: settingCellID)
        tableView.register(UINib(nibName: deleteCllID, bundle: nil), forCellReuseIdentifier: deleteCllID)
        distanceSliderBtn.cornerRadiusView(radius: 8)
        ageSliderBtn.cornerRadiusView(radius: 8)
        
        distanceSliderView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 40)
        ageSliderView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 40)
        
        settingSubView.cornerRadiusView(radius: 20)
    }
    
    func createDistanceSlider() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.isHidden = false
            self.ageSliderView.isHidden = true
            self.distanceSliderView.isHidden = false
        }
        
        distanceSlider.minimumValue = CGFloat(Defaults.distanceFiltering_Min)    // default is 0.0
        distanceSlider.maximumValue = CGFloat(Defaults.distanceFiltering_Max)    // default is 1.0
        
        distanceSlider.value = [CGFloat(self.manualdistancecontrol)]
        
        distanceSlider.addTarget(self, action: #selector(distanceSliderChanged(_:)), for: .valueChanged) // continuous changes
        distanceSlider.outerTrackColor = .lightGray // outside of first and last thumbs
        distanceSlider.orientation = .horizontal // default is .vertical
        distanceSlider.valueLabelPosition = .left // .notAnAttribute = don't show labels
        distanceSlider.isValueLabelRelative = false // show differences between thumbs instead of absolute values
        distanceSlider.snapStepSize = 0.1  // default is 0.0, i.e. don't snap
        distanceSlider.tintColor = UIColor.FriendzrColors.primary // color of track
        distanceSlider.trackWidth = 30
        distanceSlider.hasRoundTrackEnds = true
        distanceSlider.showsThumbImageShadow = false // wide tracks look better without thumb shadow
        distanceSlider.valueLabelFormatter.positiveSuffix = "km"
        isDistanceFilterAvailable = true
    }
    
    @objc func distanceSliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 5.0]
        
        manualDistanceLbl.text = String(describing: Double(slider.value[0]).rounded(toPlaces: 1))
        
        manualdistancecontrol = Double(slider.value[0]).rounded(toPlaces: 1)
    }
    
    func createAgeSlider() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.isHidden = false
            self.ageSliderView.isHidden = false
            self.distanceSliderView.isHidden = true
        }
        
        ageSlider.minimumValue = CGFloat(Defaults.ageFiltering_Min)    // default is 0.0
        ageSlider.maximumValue = CGFloat(Defaults.ageFiltering_Max)  // default is 1.0
        
        ageSlider.value = [CGFloat(self.ageFrom),CGFloat(self.ageTo)]
        
        ageSlider.addTarget(self, action: #selector(ageSliderChanged(_:)), for: .valueChanged) // continuous changes
        ageSlider.outerTrackColor = .lightGray // outside of first and last thumbs
        ageSlider.orientation = .horizontal // default is .vertical
        ageSlider.valueLabelPosition = .left // .notAnAttribute = don't show labels
        ageSlider.isValueLabelRelative = false // show differences between thumbs instead of absolute values
        ageSlider.snapStepSize = 1  // default is 0.0, i.e. don't snap
        ageSlider.tintColor = UIColor.FriendzrColors.primary // color of track
        ageSlider.trackWidth = 30
        ageSlider.hasRoundTrackEnds = true
        ageSlider.showsThumbImageShadow = false // wide tracks look better without thumb shadow
        isAgeFilterAvailable = true
    }
    
    @objc func ageSliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 5.0]
        
        ageFromLbl.text = String(describing: Int(slider.value[0]))
        ageToLbl.text = String(describing: Int(slider.value[1]))
        
        ageFrom = Int(slider.value[0])
        ageTo = Int(slider.value[1])
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.setupData()
        
        // handling code
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.isHidden = true
            self.distanceSliderView.isHidden = true
            self.ageSliderView.isHidden = true
        }
    }
    
    //save actions btns
    @IBAction func ageSaveBtn(_ sender: Any) {
        self.viewmodel.filteringAccordingToAge(filteringaccordingtoage: true, agefrom: ageFrom, ageto: ageTo) { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let data = data else {return}
            self.model = data
            
            DispatchQueue.main.async {
                self.setupData()
                self.transparentView.isHidden = true
                self.distanceSliderView.isHidden = true
                self.ageSliderView.isHidden = true
            }
        }
    }
    
    @IBAction func distanceSaveBtn(_ sender: Any) {
        self.viewmodel.updateManualdistanceControl(manualdistancecontrol: manualdistancecontrol, distanceFilter: true) { error, data in
            self.hideLoading()
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let data = data else {return}
            self.model = data
            
            
            DispatchQueue.main.async {
                self.setupData()
                self.transparentView.isHidden = true
                self.distanceSliderView.isHidden = true
                self.ageSliderView.isHidden = true
            }
        }
    }
}

extension SettingsVC :CLLocationManagerDelegate {
    
    func setupCLLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        self.locationLat = userLocation.coordinate.latitude
        self.locationLng = userLocation.coordinate.longitude
        Defaults.LocationLat = "\(self.locationLat)"
        Defaults.LocationLng = "\(self.locationLng)"
        
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
    
    
    //ghostmode toggle
    func ghostModeToggle(ghostMode:Bool,myAppearanceTypes:[Int]) {
        self.viewmodel.toggleGhostMode(ghostMode: ghostMode, myAppearanceTypes: myAppearanceTypes) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard data != nil else {
                return
            }
            
            self.model = data
            
            Defaults.myAppearanceTypes = data?.myAppearanceTypes ?? []
            Defaults.ghostMode = data?.ghostmode ?? false

            DispatchQueue.main.async {
                if data?.ghostmode == true {
                    if data?.myAppearanceTypes == [1] {
                        Defaults.ghostModeEveryOne = true
                    }else {
                        Defaults.ghostModeEveryOne = false
                    }
                    
                }else {
                    Defaults.ghostModeEveryOne = false
                }
            }
            
            
            DispatchQueue.main.async {
                self.setupData()
            }
        }
    }
    
    
    func onHideGhostModeTypesCallBack(_ data: [String], _ value: [Int]) -> () {
        print(data)
        print(value)
        ghostModeToggle(ghostMode: true, myAppearanceTypes:value)
    }
}

extension SettingsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0://notification
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            cell.titleLbl.text = "Push Notifications".localizedString
            cell.settingIcon.image = UIImage(named: "notifications_ic")
            
            if model?.pushnotification == true {
                cell.switchBtn.isOn = true
            }else {
                cell.switchBtn.isOn = false
            }
            
            cell.ghostModeTypeLbl.isHidden = true
            
            cell.HandleSwitchBtn = {
                if self.model?.pushnotification == true {
                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
                    self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn off notifications?".localizedString
                    
                    self.deleteAlertView?.HandleConfirmBtn = {
                        self.updateUserInterfaceForBtns()
                        
                        if self.internetConect {
                            self.viewmodel.togglePushNotification(pushNotification: false) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard data != nil else {
                                    return
                                }
                                
                                self.model = data
                                
                                DispatchQueue.main.async {
                                    self.setupData()
                                }
                            }
                        }
                        // handling code
                        UIView.animate(withDuration: 0.3, animations: {
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.deleteAlertView?.alpha = 0
                        }) { (success: Bool) in
                            self.deleteAlertView?.removeFromSuperview()
                            self.deleteAlertView?.alpha = 1
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        }
                    }
                    
                    self.deleteAlertView?.HandleCancelBtn = {
                        //handle cancel
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                    self.view.addSubview((self.deleteAlertView)!)
                }
                else {
                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
                    self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn on notifications?".localizedString
                    
                    self.deleteAlertView?.HandleConfirmBtn = {
                        self.updateUserInterfaceForBtns()
                        
                        if self.internetConect {
                            self.viewmodel.togglePushNotification(pushNotification: true) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard data != nil else {
                                    return
                                }
                                
                                self.model = data
                                
                                DispatchQueue.main.async {
                                    self.setupData()
                                }
                            }
                        }
                        // handling code
                        UIView.animate(withDuration: 0.3, animations: {
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.deleteAlertView?.alpha = 0
                        }) { (success: Bool) in
                            self.deleteAlertView?.removeFromSuperview()
                            self.deleteAlertView?.alpha = 1
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        }
                    }
                    
                    self.deleteAlertView?.HandleCancelBtn = {
                        DispatchQueue.main.async {
                            self.setupData()
                        }
                    }
                    
                    self.view.addSubview((self.deleteAlertView)!)
                    
                }
            }
            return cell
            
        case 1://ghostmode
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            cell.titleLbl.text = "Private Mode".localizedString
            cell.settingIcon.image = UIImage(named: "ghostModeSwitch_ic")
            
            if model?.ghostmode == true {
                cell.switchBtn.isOn = true
                cell.ghostModeTypeLbl.isHidden = false
                
                
                var mtypsInt:[Int] = []
                for itm in model?.myAppearanceTypes ?? [] {
                    mtypsInt.append(itm)
                }
                
                if mtypsInt.contains(where: {$0 == 1}) {
                    cell.ghostModeTypeLbl.text = "Everyone".localizedString
                }else {
                    if mtypsInt == [2] {
                        cell.ghostModeTypeLbl.text = "Men".localizedString
                    }else if mtypsInt == [3] {
                        cell.ghostModeTypeLbl.text = "Women".localizedString
                    }else if mtypsInt == [4] {
                        cell.ghostModeTypeLbl.text = "Other Gender".localizedString
                    }else if mtypsInt == [2,3] || mtypsInt == [3,2] {
                        cell.ghostModeTypeLbl.text = "Men, Women".localizedString
                    }else if mtypsInt == [2,4] ||  mtypsInt == [4,2]  {
                        cell.ghostModeTypeLbl.text = "Men, Other Gender".localizedString
                    }else if mtypsInt == [3,4] || mtypsInt == [4,3] {
                        cell.ghostModeTypeLbl.text = "Women, Other Gender".localizedString
                    }
                }
            }
            else{
                cell.switchBtn.isOn = false
                cell.ghostModeTypeLbl.isHidden = true
            }
            
            cell.HandleSwitchBtn = {
                if self.model?.ghostmode == false {
                    self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    self.alertView?.parentVC = self
                    self.alertView?.selectedHideType.removeAll()
                    self.alertView?.typeIDs.removeAll()
                    self.alertView?.typeStrings.removeAll()
                    SelectedSingleTone.isSelected = false

                    self.alertView?.onTypesCallBackResponse = self.onHideGhostModeTypesCallBack
                    
                    for item in self.alertView?.hideArray ?? [] {
                        item.isSelected = false
                        self.alertView?.tableView.reloadData()
                    }
                    for item in self.alertView?.hideArray ?? [] {
                        item.isSelected = false
                        self.alertView?.tableView.reloadData()
                    }
                    
                    //cancel view
                    self.alertView?.HandlehideViewBtn = {
//                        self.setupData()
                        cell.switchBtn.isOn = false
                        cell.ghostModeTypeLbl.isHidden = true
                        Defaults.ghostMode = self.model?.ghostmode ?? false
                    }
                    
                    self.alertView?.HandleSaveBtn = {
//                        self.setupData()
                        cell.switchBtn.isOn = true
                        cell.ghostModeTypeLbl.isHidden = false
                        Defaults.ghostMode = self.model?.ghostmode ?? false
                    }
                    
                    self.view.addSubview((self.alertView)!)
                    
                }
                
                else {
                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
                    self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn off private mode?".localizedString
                    
                    self.deleteAlertView?.HandleConfirmBtn = {
                        self.updateUserInterfaceForBtns()
                        
                        if self.internetConect {
                            self.viewmodel.toggleGhostMode(ghostMode: false, myAppearanceTypes: [0], completion: { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard data != nil else {return}
                                self.model = data
                                
                                DispatchQueue.main.async {
                                    cell.switchBtn.isOn = false
                                    cell.ghostModeTypeLbl.isHidden = true
                                    cell.ghostModeTypeLbl.text = ""
                                    Defaults.ghostMode = self.model?.ghostmode ?? false
                                }
                                
                            })
                        }
                        // handling code
                        UIView.animate(withDuration: 0.3, animations: {
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.deleteAlertView?.alpha = 0
                        }) { (success: Bool) in
                            self.deleteAlertView?.removeFromSuperview()
                            self.deleteAlertView?.alpha = 1
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        }
                    }
                    
                    self.deleteAlertView?.HandleCancelBtn = {
                        DispatchQueue.main.async {
                            cell.switchBtn.isOn = true
                            cell.ghostModeTypeLbl.isHidden = false
                            Defaults.ghostMode = self.model?.ghostmode ?? false
                        }
                    }
                    
                    self.view.addSubview((self.deleteAlertView)!)
                }
            }
            return cell
            
            //        case 2://allowlocation
            //            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            //            cell.titleLbl.text = "Allow My Location"
            //            cell.settingIcon.image = UIImage(named: "location_ic")
            //
            //            if model?.allowmylocation == true {
            //                cell.switchBtn.isOn = true
            //            }else {
            //                cell.switchBtn.isOn = false
            //            }
            //
            //            cell.HandleSwitchBtn = {
            //                if self.model?.allowmylocation == false {
            //
            //                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            //                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
            //                    self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn on your location?"
            //
            //                    self.deleteAlertView?.HandleConfirmBtn = {
            //                        self.updateUserInterfaceForBtns()
            //
            //                        if self.internetConect {
            //                            self.viewmodel.toggleAllowMyLocation(allowMyLocation: true) { error, data in
            //                                if let error = error {
            ////                                    self.showAlert(withMessage: error)
            //                                    DispatchQueue.main.async {
            //                                        self.view.makeToast(error)
            //                                    }
            //                                    return
            //                                }
            //
            //                                guard let data = data else {
            //                                    return
            //                                }
            //
            //                                Defaults.allowMyLocation = data.allowmylocation ?? false
            //
            //                                self.model = data
            //                                DispatchQueue.main.async {
            //                                    self.setupData()
            //                                }
            //
            //                                self.updateMyLocation()
            //                            }
            //                        }
            //                        // handling code
            //                        UIView.animate(withDuration: 0.3, animations: {
            //                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            //                            self.deleteAlertView?.alpha = 0
            //                        }) { (success: Bool) in
            //                            self.deleteAlertView?.removeFromSuperview()
            //                            self.deleteAlertView?.alpha = 1
            //                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            //                        }
            //                    }
            //
            //                    self.deleteAlertView?.HandleCancelBtn = {
            //                        DispatchQueue.main.async {
            //                            self.setupData()
            //                        }
            //                    }
            //                    self.view.addSubview((self.deleteAlertView)!)
            //                }else {
            //                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            //
            //                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
            //                    self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn off your location??"
            //
            //                    self.deleteAlertView?.HandleConfirmBtn = {
            //                        self.updateUserInterfaceForBtns()
            //
            //                        if self.internetConect {
            //                            self.viewmodel.toggleAllowMyLocation(allowMyLocation: false) { error, data in
            //                                if let error = error {
            ////                                    self.showAlert(withMessage: error)
            //                                    DispatchQueue.main.async {
            //                                        self.view.makeToast(error)
            //                                    }
            //                                    return
            //                                }
            //
            //                                guard let data = data else {
            //                                    return
            //                                }
            //
            //                                Defaults.allowMyLocation = data.allowmylocation ?? true
            //
            //                                self.model = data
            //
            //                                DispatchQueue.main.async {
            //                                    self.setupData()
            //                                }
            //
            //                            }
            //
            //                        }
            //                        // handling code
            //                        UIView.animate(withDuration: 0.3, animations: {
            //                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            //                            self.deleteAlertView?.alpha = 0
            //                        }) { (success: Bool) in
            //                            self.deleteAlertView?.removeFromSuperview()
            //                            self.deleteAlertView?.alpha = 1
            //                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            //                        }
            //                    }
            //
            //                    self.deleteAlertView?.HandleCancelBtn = {
            //                        DispatchQueue.main.async {
            //                            self.setupData()
            //                        }
            //                    }
            //
            //                    self.view.addSubview((self.deleteAlertView)!)
            //                }
            //            }
            //
            //            return cell
            //        case 3://darkmode
            //            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            //            cell.titleLbl.text = "Dark Mode"
            //            cell.settingIcon.image = UIImage(named: "location_ic")
            //
            //            if Defaults.darkMode == true {
            //                cell.switchBtn.isOn = true
            //            }else {
            //                cell.switchBtn.isOn = false
            //            }
            //
            //            cell.HandleSwitchBtn = {
            //                if Defaults.darkMode == false {
            //                    UIApplication.shared.windows.forEach { window in
            //                        window.overrideUserInterfaceStyle = .dark
            //                        Defaults.darkMode = true
            //                    }
            //                }else {
            //                    UIApplication.shared.windows.forEach { window in
            //                        window.overrideUserInterfaceStyle = .light
            //                        Defaults.darkMode = false
            //                    }
            //                }
            //            }
            //
            //            return cell
            
        case 2://Personal Space
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            
            if model?.personalSpace == true {
                cell.switchBtn.isOn = true
            }else {
                cell.switchBtn.isOn = false
            }
            
            cell.titleLbl.text = "Personal Space".localizedString
            cell.settingIcon.image = UIImage(named: "filterAccourdingAge_ic")
            
            cell.HandleSwitchBtn = {
                if self.model?.personalSpace == true {
                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
                    self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn off personal Space?".localizedString
                    
                    self.deleteAlertView?.HandleConfirmBtn = {
                        self.updateUserInterfaceForBtns()
                        
                        if self.internetConect {
                            self.viewmodel.togglePersonalSpace(personalSpace: false) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard data != nil else {
                                    return
                                }
                                
                                self.model = data
                                
                                DispatchQueue.main.async {
                                    self.setupData()
                                }
                                
                                DispatchQueue.main.async { //update map
//                                    NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
                                }
                            }
                        }
                        // handling code
                        UIView.animate(withDuration: 0.3, animations: {
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.deleteAlertView?.alpha = 0
                        }) { (success: Bool) in
                            self.deleteAlertView?.removeFromSuperview()
                            self.deleteAlertView?.alpha = 1
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        }
                    }
                    
                    self.deleteAlertView?.HandleCancelBtn = {
                        //handle cancel
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                    
                    self.view.addSubview((self.deleteAlertView)!)
                }
                else {
                    self.deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                    self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
                    self.deleteAlertView?.detailsLbl.text = "Randomly offset your map pin to hide exact location.".localizedString
                    
                    self.deleteAlertView?.HandleConfirmBtn = {
                        self.updateUserInterfaceForBtns()
                        
                        if self.internetConect {
                            self.viewmodel.togglePersonalSpace(personalSpace: true) { error, data in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.view.makeToast(error)
                                    }
                                    return
                                }
                                
                                guard data != nil else {
                                    return
                                }
                                
                                self.model = data
                                
                                DispatchQueue.main.async {
                                    self.setupData()
                                }
                                
                                DispatchQueue.main.async { //update map
//                                    NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
                                }
                            }
                        }
                        // handling code
                        UIView.animate(withDuration: 0.3, animations: {
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                            self.deleteAlertView?.alpha = 0
                        }) { (success: Bool) in
                            self.deleteAlertView?.removeFromSuperview()
                            self.deleteAlertView?.alpha = 1
                            self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                        }
                    }
                    
                    self.deleteAlertView?.HandleCancelBtn = {
                        DispatchQueue.main.async {
                            self.setupData()
                        }
                    }
                    
                    self.view.addSubview((self.deleteAlertView)!)
                    
                }
            }
            
            cell.ghostModeTypeLbl.isHidden = true
            return cell
            
        case 3://manual distance
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            cell.titleLbl.text = "Distance Filter".localizedString
            cell.settingIcon.image = UIImage(named: "manaualDistanceControl_ic")
            
            if model?.distanceFilter == true {
                cell.switchBtn.isOn = true
            }else {
                cell.switchBtn.isOn = false
            }
            cell.ghostModeTypeLbl.isHidden = true
            
            cell.HandleSwitchBtn = {
                if self.model?.distanceFilter == true {
                    self.viewmodel.updateManualdistanceControl(manualdistancecontrol: Defaults.distanceFiltering_Max, distanceFilter: false) { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let data = data else {return}
                        self.model = data
                        
                        
                        DispatchQueue.main.async {
                            self.setupData()
                        }
                    }
                }else {
                    self.createDistanceSlider()
                }
            }
            return cell
            
        case 4://filtring age
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingCellID, for: indexPath) as? SettingsTableViewCell else {return UITableViewCell()}
            
            if model?.filteringaccordingtoage == true {
                cell.switchBtn.isOn = true
            }else {
                cell.switchBtn.isOn = false
            }
            
            cell.titleLbl.text = "Age Filter".localizedString
            cell.settingIcon.image = UIImage(named: "filterAccourdingAge_ic")
            
            cell.HandleSwitchBtn = {
                if self.model?.filteringaccordingtoage == true {
                    self.viewmodel.filteringAccordingToAge(filteringaccordingtoage: false, agefrom: Defaults.ageFiltering_Min, ageto: Defaults.ageFiltering_Max) { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let data = data else {return}
                        self.model = data
                        
                        
                        DispatchQueue.main.async {
                            self.setupData()
                        }
                    }
                }else {
                    self.createAgeSlider()
                }
            }
            
            cell.ghostModeTypeLbl.isHidden = true
            return cell
        case 5://change password
            guard let cell = tableView.dequeueReusableCell(withIdentifier: deleteCllID, for: indexPath) as? DeleteAccountTableViewCell else {return UITableViewCell()}
            cell.titleLbl.text = "Change Password".localizedString
            cell.iconImg.image = UIImage(named: "changePassword_ic")
            return cell
        case 6://block list
            guard let cell = tableView.dequeueReusableCell(withIdentifier: deleteCllID, for: indexPath) as? DeleteAccountTableViewCell else {return UITableViewCell()}
            cell.titleLbl.text = "Block List".localizedString
            cell.iconImg.image = UIImage(named: "blocked_ic")
            return cell
//        case 6://Language
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: deleteCllID, for: indexPath) as? DeleteAccountTableViewCell else {return UITableViewCell()}
//            cell.titleLbl.text = "Language".localizedString
//            cell.iconImg.image = UIImage(named: "blocked_ic")
//            cell.langLbl.text = Language.currentLanguage()
//            return cell
        case 7://delete account
            guard let cell = tableView.dequeueReusableCell(withIdentifier: deleteCllID, for: indexPath) as? DeleteAccountTableViewCell else {return UITableViewCell()}
            cell.titleLbl.text = "Delete Account".localizedString
            cell.iconImg.image = UIImage(named: "delete_ic")
            cell.bottomView.isHidden = true
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 {
            if isDistanceFilterAvailable {
                self.createDistanceSlider()
            }else {
                return
            }
        }
        else if indexPath.row == 4 {
            if isAgeFilterAvailable {
                self.createAgeSlider()
            }else {
                return
            }
        }
        else if indexPath.row == 5 { //change password
            guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "ChangePasswordVC") as? ChangePasswordVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        else if indexPath.row == 6 { //block list
            guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "BlockedListVC") as? BlockedListVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
//        else if indexPath.row == 6 { //Language
//            self.changeLanguage()
//        }
        
        else if indexPath.row == 7 { //delete account
            deleteAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            deleteAlertView?.titleLbl.text = "Confirm?".localizedString
            deleteAlertView?.detailsLbl.text = "Are you sure you want to delete your account?".localizedString
            
            deleteAlertView?.HandleConfirmBtn = {
                self.updateUserInterfaceForBtns()
                if self.internetConect {
                    self.viewmodel.deleteAccount { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        
                        Defaults.deleteUserData()
                        KeychainItem.deleteUserIdentifierFromKeychain()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            Router().toOptionsSignUpVC()
                        }
                    }
                }else {
                    return
                }
                
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.deleteAlertView?.alpha = 0
                }) { (success: Bool) in
                    self.deleteAlertView?.removeFromSuperview()
                    self.deleteAlertView?.alpha = 1
                    self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
            
            self.view.addSubview((deleteAlertView)!)
        }
        else {
            return
        }
    }
}
