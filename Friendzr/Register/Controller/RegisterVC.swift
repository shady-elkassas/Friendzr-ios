//
//  RegisterVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/08/2021.
//

import UIKit
//import SkyFloatingLabelTextField

class RegisterVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var registerBtnView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    
    var checkUserNameVM:CheckUserNameViewModel = CheckUserNameViewModel()
    var registerVM:RegisterViewModel = RegisterViewModel()
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initBackButton()
        setup()
        clearNavigationBar()
        removeNavigationBorder()
        userNameTxt.addTarget(self, action: #selector(handleCheckUserName), for: .allEvents)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: false, BackButton: false)
    }
    
    @objc func handleCheckUserName() {
        checkUserNameVM.checkUserName(withUserName: userNameTxt.text!) { error, data in
            if let error = error {
                self.view.makeToast(error)
                return
            }
            
            guard let _ = data else {return}
            self.view.makeToast("Done successfully")
        }
    }
    
    //MARK: - Actions
    @IBAction func registerBtn(_ sender: Any) {
        self.showLoading()
        registerVM.RegisterNewUser(withUserName: userNameTxt.text!, AndEmail: emailTxt.text!, password: passwordTxt.text!) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let _ = data else {return}
            self.showAlert(withMessage: "Please check your email")
        }
    }
    
    @IBAction func showPasswordBtn(_ sender: Any) {
        passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
    }
    
    @IBAction func showConfirmPasswordBtn(_ sender: Any) {
        confirmPasswordTxt.isSecureTextEntry = !confirmPasswordTxt.isSecureTextEntry
    }
    
    @IBAction func facebookBtn(_ sender: Any) {
    }
    
    @IBAction func googleBtn(_ sender: Any) {
    }
    
    @IBAction func appleBtn(_ sender: Any) {
    }
    
    //MARK: - Helper
    func setup() {
        userNameView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        passwordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        confirmPasswordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)

        userNameView.cornerRadiusView(radius: 6)
        emailView.cornerRadiusView(radius: 6)
        passwordView.cornerRadiusView(radius: 6)
        confirmPasswordView.cornerRadiusView(radius: 6)
        
//        updateTextField(iView: userNameView, txtField: userNameTxt, placeholder: "User Name", titleLbl: "User Name")
//        updateTextField(iView: emailView, txtField: emailTxt, placeholder: "Email", titleLbl: "Email")
//        updateTextField(iView: passwordView, txtField: passwordTxt, placeholder: "Password", titleLbl: "Password")
//        updateTextField(iView: confirmPasswordView, txtField: confirmPasswordTxt, placeholder: "Confirm Password", titleLbl: "Confirm Password")
        
        
        facebookView.cornerRadiusView(radius: 6)
        googleView.cornerRadiusView(radius: 6)
        appleView.cornerRadiusView(radius: 6)
        googleView.setBorder()
        
        
        let fistColor = UIColor.color("#7BE495")!
        let lastColor = UIColor.color("#329D9C")!
        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
        gradient.frame = registerBtn.frame
        registerBtn.layer.addSublayer(gradient)
        registerBtn.cornerRadiusView(radius: 8)
        registerBtnView.cornerRadiusView(radius: 8)
    }
}
