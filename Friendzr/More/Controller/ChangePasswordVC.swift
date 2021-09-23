//
//  ChangePasswordVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/09/2021.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        setupViews()
        clearNavigationBar()
        removeNavigationBorder()
    }
    
    //MARK: - Helpers
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
        self.showLoading()
        viewmodel.changePasswordRequest(witholdPassword: oldPasswordTxt.text!, AndNewPassword: newPasswordTxt.text!, AndConfirmNewPassword: confirmNewPasswordTxt.text!) { error, data in
            self.hideLoading()
            if let error = error{
                self.showAlert(withMessage: error)
                return
            }
            guard let _ = data else {return}
            self.showAlert(withMessage:"Password changed successfully".localizedString)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 , execute: {
                self.oldPasswordTxt.text = ""
                self.newPasswordTxt.text = ""
                self.confirmNewPasswordTxt.text = ""
            })
        }
    }
    
    @IBAction func showPassBtn(_ sender: Any) {
        oldPasswordTxt.isSecureTextEntry = !oldPasswordTxt.isSecureTextEntry
    }
    
    @IBAction func showNewPassBtn(_ sender: Any) {
        newPasswordTxt.isSecureTextEntry = !newPasswordTxt.isSecureTextEntry
    }
    
    @IBAction func showConfirmNewPassBtn(_ sender: Any) {
        confirmNewPasswordTxt.isSecureTextEntry = !confirmNewPasswordTxt.isSecureTextEntry
    }
}
