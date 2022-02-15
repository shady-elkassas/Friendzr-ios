//
//  FriendsShareTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 10/02/2022.
//

import UIKit

class FriendsShareTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyLbl: UILabel!
    
    var cellID = "ShareTableViewCell"
    var parentVC = UIViewController()
    var myFriendsModel:[UserConversationModel]? = nil
    var isSearch:Bool = false
    var HandleSearchBtn: (() -> ())?
    
    var onSearchFriendsCallBackResponse: ((_ data: String, _ value: Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        setupSearchBar()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchContainerView.cornerRadiusView(radius: 6)
        searchContainerView.setBorder()
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.textColor = .black
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 12)
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search...".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchBar.searchTextField.attributedPlaceholder = placeHolder
        searchBar.searchTextField.addTarget(self, action: #selector(self.updateSearchFriendsResult), for: .editingChanged)
        
    }
}

extension FriendsShareTableViewCell:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriendsModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
        let model = myFriendsModel?[indexPath.row]
        cell.titleLbl.text = model?.userName
        cell.HandleSendBtn = {
            
        }
        return cell
    }
    
    
}

extension FriendsShareTableViewCell:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}


extension FriendsShareTableViewCell: UISearchBarDelegate{
    @objc func updateSearchFriendsResult() {
        guard let text = searchBar.text else {return}
        print(text)
        if text != "" {
            onSearchFriendsCallBackResponse?(text,true)
            self.parentVC.view.endEditing(false)
        }else {
            onSearchFriendsCallBackResponse?(text,false)
            self.parentVC.view.endEditing(true)
        }
    }
}
