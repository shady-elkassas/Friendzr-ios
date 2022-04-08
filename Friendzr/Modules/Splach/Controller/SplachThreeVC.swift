//
//  SplachThreeVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit

class SplachThreeVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBOutlet weak var bottomLAyoutConstraint: NSLayoutConstraint!
    var selectVC:String = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Defaults.availableVC = "SplachThreeVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        pageControl.currentPage = 2
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        
        
        if Defaults.isIPhoneLessThan1500 {
            bottomLAyoutConstraint.constant = 55
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        hideNavigationBar(NavigationBar: true, BackButton: true)
        if selectVC == "MoreVC" {
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            skipBtn.setTitle("Exit", for: .normal)
        }
        else {
            hideNavigationBar(NavigationBar: true, BackButton: true)
            skipBtn.setTitle("SKIP", for: .normal)
        }
    }
    
    //MARK: - Actions
    @IBAction func nextBtn(_ sender: Any) {
        
        if selectVC == "MoreVC" {
            guard let vc = UIViewController.viewController(withStoryboard: .Splach, AndContollerID: "SplachFourVC") as? SplachFourVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            Router().toSplach4()
        }
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            Router().toMore()
        }
        else {
            Router().toEditProfileVC(needUpdate: true)
        }
    }
}
