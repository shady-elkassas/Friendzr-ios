//
//  WelcomeVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 29/06/2022.
//

import UIKit

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var takeTourBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        takeTourBtn.cornerRadiusForHeight()
        signupBtn.cornerRadiusForHeight()
    }
    
    
    @IBAction func signupBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Register, AndContollerID: "OptionsSignUpVC") as? OptionsSignUpVC else {return}
        Defaults.isFirstLogin = false
        vc.isOpenVC = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func takeTourBtn(_ sender: Any) {
        Router().toFeed()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Login, AndContollerID: "LoginVC") as? LoginVC else {return}
        Defaults.isFirstLogin = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
