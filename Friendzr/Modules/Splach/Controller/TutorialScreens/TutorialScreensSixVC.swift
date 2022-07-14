//
//  TutorialScreensSixVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 14/07/2022.
//

import UIKit

class TutorialScreensSixVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var exitBTn: UIButton!

    var selectVC:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        pageControl.currentPage = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "TutorialScreensSixVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        if selectVC == "MoreVC" {
            
            initBackButton()
            hideNavigationBar(NavigationBar: false, BackButton: false)
            nextBtn.isHidden = false
            skipBtn.isHidden = true
            exitBTn.isHidden = true
            
            nextBtn.setTitle("EXIT", for: .normal)
            nextBtn.backgroundColor = .white
            nextBtn.setTitleColor(.black, for: .normal)
        }
        else {
            hideNavigationBar(NavigationBar: true, BackButton: true)
            nextBtn.isHidden = false
            skipBtn.isHidden = true
            exitBTn.isHidden = true
            
            nextBtn.setTitle("Create Your Profile", for: .normal)
        }
    }
    
    func setupViews() {
        nextBtn.cornerRadiusView(radius: 8)
        skipBtn.cornerRadiusView(radius: 8)
        exitBTn.cornerRadiusView(radius: 8)
    }
    
    //MARK: - Actions
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
    
    
    @IBAction func exitBtn(_ sender: Any) {
    }
}
