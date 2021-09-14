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

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localizedString
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        initBackButton()
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
    }
    
    @IBAction func ghostModeBtn(_ sender: Any) {
    }
    
    @IBAction func allowMyLocationBtn(_ sender: Any) {
        if allowMyLocationBtn.isOn == false {
            alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            alertView?.HandleHideFromEveryOneBtn = {
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
            
        }
    }
    
    @IBAction func changeEmailBtn(_ sender: Any) {
    }
    
    @IBAction func changePasswordBtn(_ sender: Any) {
    }
    
    @IBAction func deleteAccountBtn(_ sender: Any) {
        deleteAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        deleteAlertView?.titleLbl.text = "Confirm?".localizedString
        deleteAlertView?.detailsLbl.text = "Are you sure you want to delete your account?".localizedString
        
        deleteAlertView?.HandleConfirmBtn = {
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
}
