//
//  EventsShareTableViewCell.swift
//  Friendzr
//
//  Created by Shady Elkassas on 10/02/2022.
//

import UIKit

class EventsShareTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!

    var cellID = "ShareTableViewCell"
    var parentVC = UIViewController()
    var myEventsModel:[EventObj]? = nil
    var onSearchEventsCallBackResponse: ((_ data: String, _ value: Bool) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        setupSearchBar()
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension EventsShareTableViewCell:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myEventsModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
        let model = myEventsModel?[indexPath.row]
        cell.titleLbl.text = model?.title
        return cell
    }
    
    
}

extension EventsShareTableViewCell:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}

extension EventsShareTableViewCell: UISearchBarDelegate{
    @objc func updateSearchFriendsResult() {
        guard let text = searchBar.text else {return}
        print(text)
        if text != "" {
            onSearchEventsCallBackResponse?(text,true)
        }else {
            onSearchEventsCallBackResponse?(text,false)
        }
    }
}
