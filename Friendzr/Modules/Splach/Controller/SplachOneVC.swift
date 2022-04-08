//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import LocalAuthentication

class SplachOneVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var splachImg: UIImageView!
    
    @IBOutlet weak var bottomLAyoutConstraint: NSLayoutConstraint!
    var selectVC:String = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 0
        startBtn.cornerRadiusForHeight()
        startBtn.layer.applySketchShadow()
        
        splachImg.cornerRadiusView(radius: 12)
        splachImg.layer.applySketchShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachOneVC"
        print("availableVC >> \(Defaults.availableVC)")
                
        
        if Defaults.isIPhoneLessThan1500 {
            bottomLAyoutConstraint.constant = 55
        }
        
        if selectVC == "MoreVC" {
            startBtn.setTitle("NEXT", for: .normal)
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
        }
        else {
            startBtn.setTitle("GET STARTED", for: .normal)
            hideNavigationBar(NavigationBar: true, BackButton: true)
        }
    }
    
    //MARK: - Actions
    @IBAction func getStartBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            guard let vc = UIViewController.viewController(withStoryboard: .Splach, AndContollerID: "SplachTwoVC") as? SplachTwoVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            Router().toSplach2()
        }
    }
}
