//
//  GenderDistributionVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 05/10/2021.
//

import UIKit
import SwiftUI

class GenderDistributionVC: UIViewController {

    @IBOutlet weak var genderDistributionView: UIView!
    @IBOutlet weak var genderDistributionChart: UIView!
    @IBOutlet weak var tvContainerView: UIView!
    @IBOutlet weak var tvContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    let cellID = "InterestsTableViewCell"
    var model: PeopleAroundMeObj? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        initCloseBarButton()
        title = "Gender Distribution"
        setupNavBar()
    }
    
    func setupView() {
        let child = UIHostingController(rootView: CircleView(fill1: 0, fill2: 0, fill3: 0, animations: true, male: 70, female: 50, other: 40))
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.frame = CGRect(x: 0, y: 0, width: genderDistributionChart.bounds.width, height: genderDistributionChart.bounds.height)
        child.loadView()
        genderDistributionChart.addSubview(child.view)

        genderDistributionView.shadow()
        tvContainerView.shadow()
        genderDistributionView.cornerRadiusView(radius: 20)
        tvContainerView.cornerRadiusView(radius: 8)

        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tvContainerViewHeight.constant = CGFloat(3*50) + 20
    }
}

extension GenderDistributionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InterestsTableViewCell else {return UITableViewCell()}
        
        if indexPath.row == 3 {
            cell.bottonView.isHidden = true
        }
        
        cell.lblColor.backgroundColor = UIColor.colors.random()
        
        return cell
    }
}

extension GenderDistributionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
