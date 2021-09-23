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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
     
        pageControl.currentPage = 1
        nextBtn.cornerRadiusForHeight()
        nextBtn.layer.applySketchShadow()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideNavigationBar(NavigationBar: true, BackButton: true)
    }
    
    //MARK: - Actions
    @IBAction func nextBtn(_ sender: Any) {
        Router().toSplach3()
    }
}
