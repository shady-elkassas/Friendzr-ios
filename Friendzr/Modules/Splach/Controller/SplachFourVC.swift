//
//  SplachFourVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit

class SplachFourVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var selectVC:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 3
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        containerView.layer.applySketchShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachFourVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        //        hideNavigationBar(NavigationBar: true, BackButton: true)
        if selectVC == "MoreVC" {
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            nextBtn.isHidden = true
            skipBtn.isHidden = true
        }
        else {
            hideNavigationBar(NavigationBar: true, BackButton: true)
            nextBtn.isHidden = false
            skipBtn.isHidden = false
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
}
