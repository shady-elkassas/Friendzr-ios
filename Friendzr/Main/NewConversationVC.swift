//
//  NewConversationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 19/08/2021.
//

import UIKit

class NewConversationVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let cellID = "ContactsTableViewCell"
    var viewmodel:AllFriendesViewModel = AllFriendesViewModel()
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Conversation"
        initCloseBarButton()
        setupNavBar()
        setupSearchBar()
        setupViews()
        
        getAllFriends()
    }
    
    //MARK: - Helper
    func setupSearchBar() {
        searchbar.delegate = self
        searchBarView.cornerRadiusView(radius: 6)
        searchBarView.setBorder()
        searchbar.backgroundImage = UIImage()
        searchbar.searchTextField.textColor = .black
        searchbar.searchTextField.backgroundColor = .clear
        searchbar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        var placeHolder = NSMutableAttributedString()
        let textHolder  = "Search Messages".localizedString
        let font = UIFont(name: "Montserrat-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14)
        placeHolder = NSMutableAttributedString(string:textHolder, attributes: [NSAttributedString.Key.font: font])
        searchbar.searchTextField.attributedPlaceholder = placeHolder
        searchbar.searchTextField.addTarget(self, action: #selector(updateSearchResult), for: .editingChanged)
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    
    //MARK:- APIs
    func getAllFriends() {
        self.showLoading()
        viewmodel.getAllFriendes()
        viewmodel.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
}

//MARK: - Extensions
extension NewConversationVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
    }
}

extension NewConversationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.friends.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ContactsTableViewCell else {return UITableViewCell()}
        let model = viewmodel.friends.value?[indexPath.row]
        cell.nameLbl.text = model?.userName
        cell.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        if indexPath.row == ((viewmodel.friends.value?.count ?? 0) - 1 ) {
            cell.underView.isHidden = true
        }
        
        return cell
    }
}

extension NewConversationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let model = viewmodel.friends.value?[indexPath.row]
//        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
//        vc.userID = model?.userid ?? ""
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
}
