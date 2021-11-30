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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 3
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
        containerView.layer.applySketchShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: true, BackButton: true)
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        Router().toEditProfileVC()
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC()
    }
}
