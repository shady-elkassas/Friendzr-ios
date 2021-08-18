//
//  OptionsSignUpVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/08/2021.
//

import UIKit

class OptionsSignUpVC: UIViewController {

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var appleView: UIView!
    @IBOutlet weak var googleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: true, BackButton: true)
    }
    
    func setup() {
        emailView.cornerRadiusView(radius: 6)
        facebookView.cornerRadiusView(radius: 6)
        appleView.cornerRadiusView(radius: 6)
        googleView.cornerRadiusView(radius: 6)
        googleView.setBorder()
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Login, AndContollerID: "LoginVC") as? LoginVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func emailBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Register, AndContollerID: "RegisterVC") as? RegisterVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func facebookBtn(_ sender: Any) {
    }
    
    @IBAction func googleBtn(_ sender: Any) {
    }
    
    @IBAction func appleBtn(_ sender: Any) {
    }
}
