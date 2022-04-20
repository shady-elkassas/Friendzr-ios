//
//  SplachFiveVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 20/04/2022.
//

import UIKit

class SplachFiveVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - Properties
    var selectVC:String = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Defaults.availableVC = "SplachFiveVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        pageControl.currentPage = 3
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        
        
        if Defaults.isIPhoneLessThan1500 {
            bottomLayoutConstraint.constant = 55
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
