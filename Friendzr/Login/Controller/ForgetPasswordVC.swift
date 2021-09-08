//
//  ForgetPasswordVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit
//import SkyFloatingLabelTextField

class ForgetPasswordVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var resetBtnView: UIView!
    @IBOutlet weak var resetBtn: UIButton!

    //MARK: - Properties
    var viewmodel:ForgetPasswordViewModel = ForgetPasswordViewModel()
    
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
    }
    
    //MARK: - Actions
    @IBAction func resetBtn(_ sender: Any) {
        viewmodel.ResetPassword(withEmail: emailTxt.text!) { error, data in
            self.hideLoading()
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            guard let data = data else {return}
            self.showAlert(withMessage: data.code)
        }
    }
    
    //MARK: - Helpers
    func setup() {
        emailView.setBorder(color: UIColor.color("#DDDFDD")?.cgColor, width: 1)
        emailView.cornerRadiusView(radius: 6)
        
//        updateTextField(iView: emailView, txtField: emailTxt, placeholder: "Email", titleLbl: "Email")
        let fistColor = UIColor.color("#7BE495")!
        let lastColor = UIColor.color("#329D9C")!
        let gradient = CAGradientLayer(start: .topLeft, end: .bottomRight, colors: [fistColor.cgColor,lastColor.cgColor], type: .radial)
        gradient.frame = resetBtn.frame
        resetBtn.layer.addSublayer(gradient)
        resetBtn.cornerRadiusView(radius: 8)
        resetBtnView.cornerRadiusView(radius: 8)
    }
}
