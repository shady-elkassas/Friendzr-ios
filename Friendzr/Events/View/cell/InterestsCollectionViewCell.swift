//
//  InterestsCollectionViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/17/21.
//

import UIKit

class InterestsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var model:[InterestsObj]? = nil
    let cellID = "InterestsTableViewCell"
    var parentVC = UIViewController()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        containerView.cornerRadiusView(radius: 8)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

extension InterestsCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? InterestsTableViewCell else {return UITableViewCell()}
        
        let model = model?[indexPath.row]
        
        cell.interestNameLbl.text = model?.name
        cell.percentageLbl.text = "\(model?.interestcount ?? 0) %"
        
        if indexPath.row == 3 {
            cell.bottonView.isHidden = true
        }
        
        if indexPath.row == 0 {
            cell.lblColor.backgroundColor = UIColor.blue
            
        }else if indexPath.row == 1 {
            cell.lblColor.backgroundColor = UIColor.red
            
        }else {
            cell.lblColor.backgroundColor = UIColor.green
        }
        
        return cell
    }
}

extension InterestsCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

