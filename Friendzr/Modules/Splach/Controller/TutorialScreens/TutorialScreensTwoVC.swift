//
//  TutorialScreensTwoVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 14/07/2022.
//

import UIKit

class TutorialScreensTwoVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var exitBTn: UIButton!

    var selectVC:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        pageControl.currentPage = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TutorialScreensTwoVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        if selectVC == "MoreVC" {
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            skipBtn.isHidden = true
            exitBTn.isHidden = false
        }
        else {
            hideNavigationBar(NavigationBar: true, BackButton: true)
            skipBtn.isHidden = false
            exitBTn.isHidden = true
        }
    }
    
    func setupViews() {
        nextBtn.cornerRadiusView(radius: 8)
        skipBtn.cornerRadiusView(radius: 8)
        exitBTn.cornerRadiusView(radius: 8)
    }
    
    
    @IBAction func nextBtn(_ sender: Any) {
        if selectVC == "MoreVC" {
            guard let vc = UIViewController.viewController(withStoryboard: .TutorialScreens, AndContollerID: "TutorialScreensThreeVC") as? TutorialScreensThreeVC else {return}
            vc.selectVC = "MoreVC"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            Router().toSTutorialScreensThreeVC()
        }
    }
    
    
    @IBAction func skipBtn(_ sender: Any) {
        Router().toEditProfileVC(needUpdate: true)
    }
    
    @IBAction func exitBtn(_ sender: Any) {
        Router().toMore()
    }
}
