//
//  SettingsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 16/08/2021.
//

import UIKit

class SettingsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var pushNotificationView: UIView!
    @IBOutlet weak var deleteAccountView: UIView!
    @IBOutlet weak var allowMyLocationBtn: UISwitch!
    @IBOutlet weak var ghostModeBtn: UISwitch!
    @IBOutlet weak var pushNotificationBtn: UISwitch!
    
    //MARK: - Properties
    lazy var alertView = Bundle.main.loadNibNamed("HideMyLocationView", owner: self, options: nil)?.first as? HideMyLocationView
    
    lazy var deleteAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var viewmodel:SettingsViewModel = SettingsViewModel()
    var allowmylocationtype:Int = 0
    var model:SettingsObj? = nil
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localizedString
        setup()
        getUserSettings()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        initBackButton()
    }
    
    //MARK:- APIs
    func getUserSettings() {
//        self.showLoading()
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
        if model?.allowmylocation == true {
            allowMyLocationBtn.isOn = true
        }else {
            allowMyLocationBtn.isOn = false
        }
        
        if model?.ghostmode == true {
            ghostModeBtn.isOn = true
        }else {
            ghostModeBtn.isOn = false
        }
        
        if model?.pushnotification == true {
            pushNotificationBtn.isOn = true
        }else {
            pushNotificationBtn.isOn = false
        }
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
    func setup() {
        allowMyLocationBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        ghostModeBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        pushNotificationBtn.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        pushNotificationView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 16)
        deleteAccountView.setCornerforBottom(withShadow: false, cornerMask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 16)
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
    
    
    func updateSettingAlert(message:String) {
        deleteAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        deleteAlertView?.titleLbl.text = "Confirm?".localizedString
        deleteAlertView?.detailsLbl.text = message
        
        deleteAlertView?.HandleConfirmBtn = {
            self.updateSetting()
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
