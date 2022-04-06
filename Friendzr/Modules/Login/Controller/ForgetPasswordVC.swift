//
//  ForgetPasswordVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit
import Network

class ForgetPasswordVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var resetBtnView: GradientView2!
    
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
    
    //MARK: - Actions
    @IBAction func resetBtn(_ sender: Any) {
        hideKeyboard()
        if internetConect {
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
        }else {
            return
        }
    }
    
    //MARK: - Helpers
    func setup() {
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.cornerRadiusView(radius: 6)
        
        //Create Gradient in reset Btn
//        let fistColor = UIColor.color("#7BE495")!
//        let lastColor = UIColor.color("#329D9C")!
//        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
//        gradient.frame = resetBtn.frame
//        resetBtn.layer.addSublayer(gradient)
        resetBtn.cornerRadiusView(radius: 8)
        resetBtnView.cornerRadiusView(radius: 8)
    }
    
    func updateUserInterface() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.internetConect = true
                }
                return
            }else {
                DispatchQueue.main.async {
                    self.internetConect = false
                    self.HandleInternetConnection()
                }
                return
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
}
