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
    
    @IBOutlet weak var bottomLAyoutConstraint: NSLayoutConstraint!

    var selectVC:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 3
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        containerView.layer.applySketchShadow()
        
        
        if Defaults.isIPhoneLessThan1500 {
            bottomLAyoutConstraint.constant = 55
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SplachFourVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        //        hideNavigationBar(NavigationBar: true, BackButton: true)
        if selectVC == "MoreVC" {
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            nextBtn.isHidden = false
            skipBtn.isHidden = true

            nextBtn.setTitle("Exit", for: .normal)
        }
        else {
            hideNavigationBar(NavigationBar: true, BackButton: true)
            nextBtn.isHidden = false
            skipBtn.isHidden = true
            nextBtn.setTitle("NEXT", for: .normal)
        }
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            Router().toMore()
        }else {
            Router().toEditProfileVC(needUpdate: true)
        }
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
}
