//
//  SplachVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/08/2021.
//

import UIKit

class SplachOneVC: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var splachImg: UIImageView!
    
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
    
    @IBAction func getStartBtn(_ sender: Any) {
//        Router().toSplach2()
        Router().toHome()
    }
}
