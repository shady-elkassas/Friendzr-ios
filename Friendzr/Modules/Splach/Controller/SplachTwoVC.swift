//
//  SplachTwoVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit

class SplachTwoVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var bottomLAyoutConstraint: NSLayoutConstraint!
    
    var selectVC:String = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 1
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachTwoVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        //        hideNavigationBar(NavigationBar: true, BackButton: true)
        
        if selectVC == "MoreVC" {
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            skipBtn.isHidden = true
        }
        else {
            hideNavigationBar(NavigationBar: true, BackButton: true)
            skipBtn.isHidden = false
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
        Router().toEditProfileVC(needUpdate: true)
    }
}
