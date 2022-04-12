//
//  SplachTwoVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit

class SplachTwoVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var bottomLAyoutConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    var selectVC:String = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 1
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        
        
        if Defaults.isIPhoneLessThan1500 {
            bottomLAyoutConstraint.constant = 55
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachTwoVC"
        print("availableVC >> \(Defaults.availableVC)")
        
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
            guard let vc = UIViewController.viewController(withStoryboard: .Splach, AndContollerID: "SplachThreeVC") as? SplachThreeVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            Router().toSplach3()
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
