//
//  GenderDistributionVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 05/10/2021.
//

import UIKit
import SwiftUI

class GenderDistributionVC: UIViewController {

    @IBOutlet weak var genderDistributionView: UIView!
    @IBOutlet weak var genderDistributionChart: UIView!
    @IBOutlet weak var tvContainerView: UIView!
    @IBOutlet weak var tvContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var hideView: UIView!
    
    let cellID = "InterestsTableViewCell"
    var genderbylocationVM: GenderbylocationViewModel = GenderbylocationViewModel()
    
    var lat:Double = 0.0
    var lng:Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        initCloseBarButton()
        title = "Gender Distribution"
        setupNavBar()
        
        getGenderbylocation(lat: lat, lng: lng)
    }
    
    func getGenderbylocation(lat:Double,lng:Double) {
        self.showLoading()
        genderbylocationVM.getGenderbylocation(ByLat: lat, AndLng: lng)
        genderbylocationVM.gender.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                hideView.isHidden = true
                let child = UIHostingController(rootView: CircleView(fill1: 0, fill2: 0, fill3: 0, animations: true, male: Int(value.malePercentage ?? 0.0), female: Int(value.femalepercentage ?? 0.0), other: Int(value.otherpercentage ?? 0.0)))
                child.view.translatesAutoresizingMaskIntoConstraints = true
                child.view.frame = CGRect(x: 0, y: 0, width: genderDistributionChart.bounds.width, height: genderDistributionChart.bounds.height)
                child.loadView()
                genderDistributionChart.addSubview(child.view)
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        genderbylocationVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    
    func setupView() {

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
        
        let model = genderbylocationVM.gender.value
        
        if indexPath.row == 0 {
            cell.interestNameLbl.text = "Male"
            cell.lblColor.backgroundColor = UIColor.blue
            cell.percentageLbl.text = "\(model?.malePercentage ?? 0) %"
        }else if indexPath.row == 1 {
            cell.interestNameLbl.text = "Female"
            cell.lblColor.backgroundColor = UIColor.red
            cell.percentageLbl.text = "\(model?.femalepercentage ?? 0) %"
        }else {
            cell.interestNameLbl.text = "Other"
            cell.lblColor.backgroundColor = UIColor.green
            cell.percentageLbl.text = "\(model?.otherpercentage ?? 0) %"
        }
        
        
        if indexPath.row == 3 {
            cell.bottonView.isHidden = true
        }
        
        return cell
    }
}

extension GenderDistributionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
