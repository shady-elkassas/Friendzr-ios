//
//  FiltringDirectionVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 22/09/2021.
//

import UIKit
import SwiftUI

class FiltringDirectionVC: UIViewController {

    @IBOutlet weak var CompassView: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton()
        title = "Filtring Direction"
        setupView()
    }
    
    func setupView() {
        filterBtn.cornerRadiusView(radius: 8)
        let child = UIHostingController(rootView: CompassViewSwiftUI())
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.sizeToFit()
        child.view.frame = CGRect(x: 0, y: 0, width: CompassView.bounds.width - 20, height: CompassView.bounds.height - 100)
        CompassView.addSubview(child.view)
    }
    
    @IBAction func filterBtn(_ sender: Any) {
        
    }
}
