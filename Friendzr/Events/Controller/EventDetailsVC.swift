//
//  EventDetailsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import UIKit
import Charts
import SwiftUI

class EventDetailsVC: UIViewController {

    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var dateCreateLbl: UILabel!
    @IBOutlet weak var timeCreateLbl: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var attendLbl: UILabel!
    @IBOutlet weak var statisticsView: UIView!
    @IBOutlet weak var malePercentageLbl: UILabel!
    @IBOutlet weak var femalePercentageLbl: UILabel!
    @IBOutlet weak var otherPercentageLbl: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var descreptionLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    
    var numbers:[Double] = [1,2,3]
    var genders:[String] = ["Men","Women","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButton(btnColor: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearNavigationBar()
        setupViews()
    }
    
    func setupViews() {
        let child = UIHostingController(rootView: CircleView())
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.frame = CGRect(x: 0, y: 0, width: chartView.bounds.width, height: chartView.bounds.height)
        chartView.addSubview(child.view)
        chartContainerView.cornerRadiusView(radius: 21)
        
        editBtn.cornerRadiusView(radius: 8)
        joinBtn.cornerRadiusView(radius: 8)
        leaveBtn.cornerRadiusView(radius: 8)
        detailsView.cornerRadiusView(radius: 21)
        statisticsView.cornerRadiusView(radius: 21)
    }
    
    @IBAction func editBtn(_ sender: Any) {
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EditEventsVC") as? EditEventsVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func joinBtn(_ sender: Any) {
    }
    
    @IBAction func leaveBtn(_ sender: Any) {
    }
}
