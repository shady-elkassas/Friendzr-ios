//
//  GenderDistributionView.swift
//  Friendzr
//
//  Created by Shady Elkassas on 05/10/2021.
//

import UIKit
import SwiftUI

class GenderDistributionView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var genderDistributionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    let cellID = "InterestsTableViewCell"
    var parentVC = UIViewController()
    
    var male:Int = 0
    var female:Int = 60
    var other:Int = 0
    
    var showGenderDistribution:Bool = false
    
    override func awakeFromNib() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        
        containerView.cornerRadiusView(radius: 12)
        setupView()
    }
    
    func setupView() {
        let child = UIHostingController(rootView: CircleView(fill1: 0, fill2: 0, fill3: 0, animations: true, male: male, female: female, other: other))
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.frame = CGRect(x: 0, y: 0, width: genderDistributionView.bounds.width, height: genderDistributionView.bounds.height)
        child.loadView()
        genderDistributionView.addSubview(child.view)
        
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableViewHeight.constant = CGFloat(3*50) + 20
    }
}

extension GenderDistributionView: UITableViewDataSource {
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

extension GenderDistributionView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
