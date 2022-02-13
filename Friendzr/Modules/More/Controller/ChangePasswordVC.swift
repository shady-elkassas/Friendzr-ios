//
//  ChangePasswordVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/09/2021.
//

import UIKit

class ChangePasswordVC: UIViewController  {
    
    //MARK:- Outlets
    @IBOutlet var views: [UIView]!
    @IBOutlet weak var oldPasswordTxt: UITextField!
    @IBOutlet weak var newPasswordTxt: UITextField!
    @IBOutlet weak var confirmNewPasswordTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveBtnView: UIView!
    @IBOutlet weak var showConfirmNewPasswordBtn: UIButton!
    @IBOutlet weak var showNewPasswordBtn: UIButton!
    @IBOutlet weak var showPasswordBtn: UIButton!
    
    //MARK: - Properties
    var viewmodel:ChangePasswordViewModel = ChangePasswordViewModel()
    var internetConect:Bool = false

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setupViews()
        clearNavigationBar()
        removeNavigationBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    //MARK: - Helpers
    func updateUserInterface() {
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
        self.view.makeToast("No available network, please try again!".localizedString)
    }

    
    func setupViews() {
        for item in views {
            item.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
            item.cornerRadiusView(radius: 6)
        }
        
        let fistColor = UIColor.color("#7BE495")!
        let lastColor = UIColor.color("#329D9C")!
        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
        gradient.frame = saveBtn.frame
        saveBtn.layer.addSublayer(gradient)
        saveBtn.cornerRadiusView(radius: 8)
        saveBtnView.cornerRadiusView(radius: 8)
    }
    
    //MARK:- Actions
    @IBAction func saveBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect {
            self.saveBtn.setTitle("Saving...", for: .normal)
            self.saveBtn.isUserInteractionEnabled = false
            viewmodel.changePasswordRequest(witholdPassword: oldPasswordTxt.text!, AndNewPassword: newPasswordTxt.text!, AndConfirmNewPassword: confirmNewPasswordTxt.text!) { error, data in
                self.saveBtn.setTitle("Save", for: .normal)
                self.saveBtn.isUserInteractionEnabled = true
                
                if let error = error{
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                guard let _ = data else {return}
//                DispatchQueue.main.async {
//                    self.view.makeToast("Password changed successfully".localizedString)
//                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                    self.onPopup()
                })
            }
        }else {
            return
        }
    }
    
    @IBAction func showPassBtn(_ sender: Any) {
        oldPasswordTxt.isSecureTextEntry = !oldPasswordTxt.isSecureTextEntry
        self.showPasswordBtn.isSelected = !self.showPasswordBtn.isSelected
    }
    
    @IBAction func showNewPassBtn(_ sender: Any) {
        newPasswordTxt.isSecureTextEntry = !newPasswordTxt.isSecureTextEntry
        self.showNewPasswordBtn.isSelected = !self.showNewPasswordBtn.isSelected
    }
    
    @IBAction func showConfirmNewPassBtn(_ sender: Any) {
        confirmNewPasswordTxt.isSecureTextEntry = !confirmNewPasswordTxt.isSecureTextEntry
        self.showConfirmNewPasswordBtn.isSelected = !self.showConfirmNewPasswordBtn.isSelected
    }
}
