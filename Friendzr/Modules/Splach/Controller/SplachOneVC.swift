//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit
import LocalAuthentication

class SplachOneVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var splachImg: UIImageView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.currentPage = 0
        startBtn.cornerRadiusForHeight()
        startBtn.layer.applySketchShadow()
        
        splachImg.cornerRadiusView(radius: 12)
        splachImg.layer.applySketchShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: true, BackButton: true)
    }
    
    //MARK: - Actions
    @IBAction func getStartBtn(_ sender: Any) {
//        if Defaults.needUpdate == 1 {{
//            Router().toEditProfileVC()
//        }else {
//            if Defaults.token != "" {
//                Router().toFeed()
//            }else {
//                Router().toSplach2()
//            }
//        }}
        
        Router().toSplach2()
    }
}
