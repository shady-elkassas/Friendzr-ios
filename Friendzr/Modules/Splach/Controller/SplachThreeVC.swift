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

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Defaults.availableVC = "SplachThreeVC"
        print("availableVC >> \(Defaults.availableVC)")

        pageControl.currentPage = 2
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: true, BackButton: true)
    }
    
    //MARK: - Actions
    @IBAction func nextBtn(_ sender: Any) {
        Router().toSplach4()
    }
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
}
