//
//  FiltringDirectionVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 22/09/2021.
//

import UIKit
import SwiftUI

class FiltringDirectionVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var CompassView: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        title = "Filtring Direction"
        setupView()
    }
    
    //MARK: - Helper
    func setupView() {
        filterBtn.cornerRadiusView(radius: 8)
        
        //add Compass View Swift UI in view
        let child = UIHostingController(rootView: CompassViewSwiftUI())
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.sizeToFit()
        child.view.frame = CGRect(x: 0, y: 0, width: CompassView.bounds.width, height: CompassView.bounds.height - 100)
        CompassView.addSubview(child.view)
    }
    
    //MARK:- Actions
    @IBAction func filterBtn(_ sender: Any) {
    }
}
