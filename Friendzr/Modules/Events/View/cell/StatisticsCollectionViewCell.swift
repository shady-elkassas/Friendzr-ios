//
//  StatisticsCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 11/01/2022.
//

import UIKit

class StatisticsCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var interestContainerView: UIView!
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var genderTV: UITableView!
    @IBOutlet weak var interestTV: UITableView!
    
    
    let cellID = "InterestsTableViewCell"
    
    var genderModel:[GenderObj]? = nil
    var interestModel:[InterestsObj]? = nil
    var parentVC = UIViewController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupViews()
    }
    
    
    func setupViews() {
        superView.cornerRadiusView(radius: 12)
        genderTV.dataSource = self
        genderTV.delegate = self
        genderTV.reloadData()
        interestTV.dataSource = self
        interestTV.delegate = self
        interestTV.reloadData()
        
        interestTV.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        genderTV.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

extension StatisticsCollectionViewCell:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InterestsTableViewCell else {return UITableViewCell()}
        
        if tableView == genderTV {
            let model = genderModel?[indexPath.row]
            
            cell.percentageLbl.text = "\(model?.gendercount ?? 0) %"
            cell.interestNameLbl.text = model?.key
            cell.sliderLbl.value = Float(model?.gendercount ?? 0)
            
            if model?.key == "Male" {
                cell.sliderLbl.minimumTrackTintColor = .blue
                if model?.gendercount == 0 {
                    cell.sliderLbl.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if model?.gendercount == 100 {
                    cell.sliderLbl.maximumTrackTintColor = .blue
                }
            }else if model?.key == "Female" {
                cell.sliderLbl.minimumTrackTintColor = .red
                if model?.gendercount == 0 {
                    cell.sliderLbl.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if model?.gendercount == 100 {
                    cell.sliderLbl.maximumTrackTintColor = .red
                }
            }else {
                cell.sliderLbl.minimumTrackTintColor = .darkGray
                if model?.gendercount == 0 {
                    cell.sliderLbl.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if model?.gendercount == 100 {
                    cell.sliderLbl.maximumTrackTintColor = .darkGray
                }
            }

        }else {
            let model = interestModel?[indexPath.row]
            
            cell.interestNameLbl.text = model?.name
            cell.percentageLbl.text = "\(model?.interestcount ?? 0) %"
            cell.sliderLbl.value = Float((model?.interestcount ?? 0))
            
            if indexPath.row == 0 {
                cell.sliderLbl.minimumTrackTintColor = .blue
                if model?.interestcount == 0 {
                    cell.sliderLbl.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if model?.interestcount == 100 {
                    cell.sliderLbl.maximumTrackTintColor = .blue
                }
            }else if indexPath.row == 1 {
                cell.sliderLbl.minimumTrackTintColor = .red
                if model?.interestcount == 0 {
                    cell.sliderLbl.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if model?.interestcount == 100 {
                    cell.sliderLbl.maximumTrackTintColor = .red
                }
            }else {
                cell.sliderLbl.minimumTrackTintColor = .green
                if model?.interestcount == 0 {
                    cell.sliderLbl.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if model?.interestcount == 100 {
                    cell.sliderLbl.maximumTrackTintColor = .green
                }
            }
        }
        
        return cell
        
    }
}

extension StatisticsCollectionViewCell:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
