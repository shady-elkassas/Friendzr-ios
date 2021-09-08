//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import LocalAuthentication

class SplachOneVC: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var splachImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.currentPage = 0
        startBtn.cornerRadiusForHeight()
        startBtn.layer.applySketchShadow()
        
        splachImg.cornerRadiusView(radius: 12)
        splachImg.layer.applySketchShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: true, BackButton: true)
    }
    
    @IBAction func getStartBtn(_ sender: Any) {
        if Defaults.token != "" {
            Router().toHome()
        }else {
            Router().toSplach2()
        }

//            let context = LAContext()
//            var error: NSError? = nil
//            let reason = "Please authorize with touch id!"
//            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
//                    DispatchQueue.main.async {
//                        guard  success,error == nil
//                        else {
//                            self?.view.makeToast("Failed, Please Tri Again.")
//                            return
//                        }
//
//                        self?.view.makeToast("Success")
//                        Router().toHome()
//                    }
//                }
//            }else {
//                self.view.makeToast("Unavilable")
//            }
    }
}
