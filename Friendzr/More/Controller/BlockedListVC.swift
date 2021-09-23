//
//  BlockedListVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/09/2021.
//

import UIKit

class BlockedListVC: UIViewController {

    //MARK:- Outlets
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let cellID = "BlockedTableViewCell"
    var viewmodel:AllBlockedViewModel = AllBlockedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()

    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Blocked List"
        initBackButton()
        setupNavBar()
        setupSearchBar()
        setupViews()
        getAllBlockedList()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        alertView?.addGestureRecognizer(tap)
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
    func getAllBlockedList() {
        self.showLoading()
        viewmodel.getAllBlockedList()
        viewmodel.blocklist.bind { [unowned self] value in
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
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        UIView.animate(withDuration: 0.3, animations: {
            self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.alertView?.alpha = 0
        }) { (success: Bool) in
            self.alertView?.removeFromSuperview()
            self.alertView?.alpha = 1
            self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }
    }
}

//MARK: - Extensions
extension BlockedListVC : UISearchBarDelegate {
    @objc func updateSearchResult() {
        guard let text = searchbar.text else {return}
        print(text)
    }
}

extension BlockedListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.blocklist.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? BlockedTableViewCell else {return UITableViewCell()}
        let model = viewmodel.blocklist.value?[indexPath.row]
        cell.nameLbl.text = model?.userName
        cell.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        if indexPath.row == ((viewmodel.blocklist.value?.count ?? 0) - 1 ) {
            cell.underView.isHidden = true
        }
        
        cell.HandleUnblockBtn = {
            self.alertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            self.alertView?.titleLbl.text = "Confirm?".localizedString
            self.alertView?.detailsLbl.text = "Are you sure you want to unblock this account?".localizedString
            
            self.alertView?.HandleConfirmBtn = {
                // handling code
                
                self.showLoading()
                self.requestFriendVM.requestFriendStatus(withID: model?.userid ?? "", AndKey: 4) { error, message in
                    self.hideLoading()
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let message = message else {return}
                    self.showAlert(withMessage: message)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    self.alertView?.alpha = 0
                }) { (success: Bool) in
                    self.alertView?.removeFromSuperview()
                    self.alertView?.alpha = 1
                    self.alertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
            
            self.view.addSubview((self.alertView)!)
        }
        
        return cell
    }
}

extension BlockedListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewmodel.blocklist.value?[indexPath.row]
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
        vc.userID = model?.userid ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
