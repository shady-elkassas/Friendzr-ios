//
//  SettingsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit
import CoreLocation
import SwiftUI
import MultiSlider

class SettingsVC: UIViewController , CLLocationManagerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var pushNotificationView: UIView!
    @IBOutlet weak var deleteAccountView: UIView!
    @IBOutlet weak var allowMyLocationBtn: UISwitch!
    @IBOutlet weak var ghostModeBtn: UISwitch!
    @IBOutlet weak var pushNotificationBtn: UISwitch!
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
    
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("HideMyLocationView", owner: self, options: nil)?.first as? HideMyLocationView
    
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
//    var btnsSelect:Bool = false
    
    var ageFrom:Int = 13
    var ageTo:Int = 100
    var manualdistancecontrol:Double = 0.2
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localizedString
        setupView()
        
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        initBackButton()
        
        setupCLLocationManager()
    }
    
    //MARK:- APIs
    func getUserSettings() {
        self.showLoading()
        viewmodel.getUserSetting()
        viewmodel.userSettings.bind { [unowned self]value in
            DispatchQueue.main.async {
                self.hideLoading()
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
        if self.model?.allowmylocation == false {
            if CLLocationManager.locationServicesEnabled(){
                self.locationManager.stopUpdatingLocation()
            }
            DispatchQueue.main.async {
                self.allowMyLocationBtn.isOn = false
                Defaults.allowMyLocation = false
            }
        }else {
            if CLLocationManager.locationServicesEnabled(){
                self.locationManager.startUpdatingLocation()
            }
            
            DispatchQueue.main.async {
                self.allowMyLocationBtn.isOn = true
                Defaults.allowMyLocation = true
            }
        }
        
        if model?.ghostmode == true {
            DispatchQueue.main.async {
                self.ghostModeBtn.isOn = true
            }
        }else {
            DispatchQueue.main.async {
                self.ghostModeBtn.isOn = false
            }
        }
        
        if model?.pushnotification == true {
            DispatchQueue.main.async {
                self.pushNotificationBtn.isOn = true
            }
        }else {
            DispatchQueue.main.async {
                self.pushNotificationBtn.isOn = false
            }
        }
        
        ageFrom = model?.agefrom ?? 13
        ageTo = model?.ageto ?? 100
        manualdistancecontrol = model?.manualdistancecontrol ?? 0.2
    }
    
    func updateSetting() {
        self.viewmodel.updatUserSetting(withPushNotification: self.pushNotificationBtn.isOn, AndAllowMyLocation: self.allowMyLocationBtn.isOn, AndGhostMode: self.ghostModeBtn.isOn,allowmylocationtype:allowmylocationtype) { error, data in
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let data = data else {return}
            self.model = data
            self.setupData()
        }
    }
    
    //MARK: - Helper
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
    
    func HandleInternetConnection() {
        self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
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
    
    func setupView() {
        allowMyLocationBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        ghostModeBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        pushNotificationBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        pushNotificationView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 16)
        deleteAccountView.setCornerforBottom(withShadow: false, cornerMask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 16)
        
        distanceSliderBtn.cornerRadiusView(radius: 8)
        ageSliderBtn.cornerRadiusView(radius: 8)
        
        distanceSliderView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 40)
        ageSliderView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 40)
    }
    
    //MARK: - Actions
    @IBAction func pushNotificationBtn(_ sender: Any) {
        if pushNotificationBtn.isOn == false {
            updateSettingAlert(message: "Are you sure you want to turn off notifications?")
        }else {
            updateSettingAlert(message: "Are you sure you want to turn on notifications?")
        }
    }
    
    @IBAction func ghostModeBtn(_ sender: Any) {
        if allowMyLocationBtn.isOn == true {
            alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            alertView?.HandleHideFromEveryOneBtn = {
                self.allowmylocationtype = 1
                
                self.updateSettingAlert(message: "Are you sure you want to turn on ghost mode from every one?")
                
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.alertView?.alpha = 0
                }) { (success: Bool) in
                    self.alertView?.removeFromSuperview()
                    self.alertView?.alpha = 1
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
            
            alertView?.HandleHideFromMenBtn = {
                self.allowmylocationtype = 2
                self.updateSettingAlert(message: "Are you sure you want to turn on ghost mode from men?")
                
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.alertView?.alpha = 0
                }) { (success: Bool) in
                    self.alertView?.removeFromSuperview()
                    self.alertView?.alpha = 1
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
            
            alertView?.HandleHideFromWomenBtn = {
                self.allowmylocationtype = 3
                
                self.updateSettingAlert(message: "Are you sure you want to turn on ghost mode from women?")
                
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.alertView?.alpha = 0
                }) { (success: Bool) in
                    self.alertView?.removeFromSuperview()
                    self.alertView?.alpha = 1
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
            
            self.view.addSubview((alertView)!)
        }else {
            self.allowmylocationtype = 0
            self.updateSettingAlert(message: "Are you sure you want to turn off ghost mode?")
        }
        
    }
    
    @IBAction func allowMyLocationBtn(_ sender: Any) {
        if allowMyLocationBtn.isOn == false {
            updateSettingAlert(message: "Are you sure you want to turn off your location?")
        }else {
            updateSettingAlert(message: "Are you sure you want to turn on your location?")
        }
    }
    
    @IBAction func changeEmailBtn(_ sender: Any) {
    }
    
    @IBAction func changePasswordBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "ChangePasswordVC") as? ChangePasswordVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteAccountBtn(_ sender: Any) {
        deleteAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        deleteAlertView?.titleLbl.text = "Confirm?".localizedString
        deleteAlertView?.detailsLbl.text = "Are you sure you want to delete your account?".localizedString
        
        deleteAlertView?.HandleConfirmBtn = {
            self.updateUserInterface()
            if self.internetConect {
                self.showLoading()
                self.viewmodel.deleteAccount { error, data in
                    self.hideLoading()
                    
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let _ = data else {return}
                    Defaults.deleteUserData()
                    KeychainItem.deleteUserIdentifierFromKeychain()
                    
                    self.showAlert(withMessage: "Account has been deleted")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
    
    @IBAction func filtingAcordingAgeBtn(_ sender: Any) {
        createAgeSlider()
    }
    
    @IBAction func manualDistanceControlBtn(_ sender: Any) {
        createDistanceSlider()
    }
    
    //save actions btns
    @IBAction func ageSaveBtn(_ sender: Any) {
        self.showLoading()
        self.viewmodel.filteringAccordingToAge(filteringaccordingtoage: true, agefrom: ageFrom, ageto: ageTo) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let data = data else {return}
            self.model = data
            self.setupData()
        }
    }
    
    @IBAction func distanceSaveBtn(_ sender: Any) {
        self.showLoading()
        self.viewmodel.updateManualdistanceControl(manualdistancecontrol: manualdistancecontrol) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let data = data else {return}
            self.model = data
            self.setupData()
        }
    }
    
    func createDistanceSlider() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        transparentView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.isHidden = false
            self.ageSliderView.isHidden = true
            self.distanceSliderView.isHidden = false
        }
        
        distanceSlider.minimumValue = 0.2    // default is 0.0
        distanceSlider.maximumValue = 50    // default is 1.0
        
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
        
    }
    
    @objc func distanceSliderChanged(_ slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)") // e.g., [1.0, 5.0]
        
        manualDistanceLbl.text = String(describing: Double(slider.value[0]).rounded(toPlaces: 1))
        
        manualdistancecontrol = Double(slider.value[0]).rounded(toPlaces: 1)
    }
    
    func createAgeSlider() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        transparentView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.isHidden = false
            self.ageSliderView.isHidden = false
            self.distanceSliderView.isHidden = true
        }
        
        ageSlider.minimumValue = 13    // default is 0.0
        ageSlider.maximumValue = 100   // default is 1.0
        
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
        // handling code
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.isHidden = true
            self.distanceSliderView.isHidden = true
            self.ageSliderView.isHidden = true
        }
    }
    
    func updateSettingAlert(message:String) {
        deleteAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        deleteAlertView?.titleLbl.text = "Confirm?".localizedString
        deleteAlertView?.detailsLbl.text = message
        
        deleteAlertView?.HandleConfirmBtn = {
            self.updateUserInterface()

            if self.internetConect {
                self.updateSetting()
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
        
        deleteAlertView?.HandleCancelBtn = {
            self.setupData()
        }
        
        self.view.addSubview((deleteAlertView)!)
    }
}
