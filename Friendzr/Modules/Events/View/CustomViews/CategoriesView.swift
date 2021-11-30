//
//  CategoriesView.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/08/2021.
//

import Foundation
import UIKit

class CategoriesView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    let catCellID = "CategoryTableViewCell"
    var parentVC = UIViewController()
    var catID = ""
    var onCategoryCallBackResponse: ((_ data: String, _ value: String) -> ())?
    var catsModel:[CategoryObj]? = [CategoryObj]()
    var catname = ""
    
    override func awakeFromNib() {
        
        containerView.shadow()
        containerView.cornerRadiusView(radius: 12)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: catCellID, bundle: nil), forCellReuseIdentifier: catCellID)
    }
}


extension CategoriesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catsModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: catCellID, for: indexPath) as? CategoryTableViewCell else {return UITableViewCell()}
        cell.titleLbl.text = catsModel?[indexPath.row].name
        return cell
    }
}

extension CategoriesView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = catsModel?[indexPath.row]
        catID = model?.id ?? ""
        catname = model?.name ?? ""
        onCategoryCallBackResponse!("\(catID)","\(catname)")
        
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alpha = 0
        }) { (success: Bool) in
            self.removeFromSuperview()
            self.alpha = 1
            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
}
