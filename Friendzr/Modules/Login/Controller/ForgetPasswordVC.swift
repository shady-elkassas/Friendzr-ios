//
//  ForgetPasswordVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit
import Network

class ForgetPasswordVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var resetBtnView: GradientView2!
    
    //MARK: - Properties
    var viewmodel:ForgetPasswordViewModel = ForgetPasswordViewModel()
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setup()
        clearNavigationBar()
        removeNavigationBorder()
        
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "ForgetPasswordVC"
        print("availableVC >> \(Defaults.availableVC)")

        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
        
        NotificationCenter.default.post(name: Notification.Name("registrationFCM"), object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - APIs
    func resetPassword() {
        self.resetBtn.setTitle("Sending...", for: .normal)
        self.resetBtn.isUserInteractionEnabled = false
        viewmodel.ResetPassword(withEmail: emailTxt.text!) { error, data in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                self.view.makeToast("Please check your email".localizedString)
                
                self.resetBtn.setTitle("Reset", for: .normal)
                self.resetBtn.isUserInteractionEnabled = true
            }
            
            DispatchQueue.main.async {
                self.onPopup()
            }
        }
    }
    //MARK: - Actions
    @IBAction func resetBtn(_ sender: Any) {
        hideKeyboard()
        if NetworkConected.internetConect {
            resetPassword()
        }else {
            return
        }
    }
    
    //MARK: - Helpers
    func setup() {
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.cornerRadiusView(radius: 6)
        resetBtn.cornerRadiusView(radius: 8)
        resetBtnView.cornerRadiusView(radius: 8)
        
        emailTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
            }
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
    
}
