//
//  RegisterVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/08/2021.
//

import UIKit
import SkyFloatingLabelTextField

class RegisterVC: UIViewController {

    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var userNameTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordTxt: SkyFloatingLabelTextField!
    @IBOutlet weak var registerBtnView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initBackButton()
        setup()
        clearNavigationBar()
        removeNavigationBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: false, BackButton: false)
    }
    
    @IBAction func registerBtn(_ sender: Any) {
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
    
    func setup() {
        userNameView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        passwordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        confirmPasswordView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)

        userNameView.cornerRadiusView(radius: 6)
        emailView.cornerRadiusView(radius: 6)
        passwordView.cornerRadiusView(radius: 6)
        confirmPasswordView.cornerRadiusView(radius: 6)
        
        updateTextField(iView: userNameView, txtField: userNameTxt, placeholder: "User Name", titleLbl: "User Name")
        updateTextField(iView: emailView, txtField: emailTxt, placeholder: "Email", titleLbl: "Email")
        updateTextField(iView: passwordView, txtField: passwordTxt, placeholder: "Password", titleLbl: "Password")
        updateTextField(iView: confirmPasswordView, txtField: confirmPasswordTxt, placeholder: "Confirm Password", titleLbl: "Confirm Password")
        
        
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
