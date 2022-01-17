//
//  ForgetPasswordVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit

class ForgetPasswordVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtnView: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    
    //MARK: - Properties
    var viewmodel:ForgetPasswordViewModel = ForgetPasswordViewModel()
    
    var internetConect:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setup()
        clearNavigationBar()
        removeNavigationBorder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: false, BackButton: false)
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - Actions
    @IBAction func resetBtn(_ sender: Any) {
        updateUserInterface()
        if internetConect {
            self.showLoading()
            viewmodel.ResetPassword(withEmail: emailTxt.text!) { error, data in
                self.hideLoading()
                if let error = error {
                    //                    self.showAlert(withMessage: error)
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                guard let _ = data else {return}
                //                self.showAlert(withMessage: "Please check your email")
                
                DispatchQueue.main.async {
                    self.view.makeToast("Please check your email".localizedString)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.onPopup()
                }
            }
        }else {
            return
        }
    }
    
    //MARK: - Helpers
    func setup() {
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.cornerRadiusView(radius: 6)
        
        //Create Gradient in reset Btn
        let fistColor = UIColor.color("#7BE495")!
        let lastColor = UIColor.color("#329D9C")!
        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
        gradient.frame = resetBtn.frame
        resetBtn.layer.addSublayer(gradient)
        resetBtn.cornerRadiusView(radius: 8)
        resetBtnView.cornerRadiusView(radius: 8)
    }
    
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
        self.view.makeToast("No avaliable network ,Please try again!".localizedString)
    }
    
}
