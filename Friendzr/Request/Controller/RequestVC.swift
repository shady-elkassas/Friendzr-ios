//
//  RequestVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class RequestVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var totalRequestLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let cellID = "RequestTableViewCell"
    var viewmodel:RequestsViewModel = RequestsViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var refreshControl = UIRefreshControl()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Request"
        setupNavBar()
        initProfileBarButton()
        getAllUserRequests()
    }
    
    //MARK:- APIs
    func getAllUserRequests() {
        self.showLoading()
        viewmodel.getAllRequests()
        viewmodel.requests.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                totalRequestLbl.text = " \(value.count)"
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
    //MARK: - Helper
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        getAllUserRequests()
        self.refreshControl.endRefreshing()
    }
    
    func setup() {
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

//MARK: - Extensions
extension RequestVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.requests.value?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? RequestTableViewCell else {return UITableViewCell()}
        let model = viewmodel.requests.value?[indexPath.row]
        
        cell.friendRequestNameLbl.text = model?.userName
        
        cell.HandleAcceptBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = false
                cell.requestRemovedLbl.isHidden = true
            }
        }
        
        cell.HandleDeleteBtn = {
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                
                cell.stackViewBtns.isHidden = true
                cell.messageBtn.isHidden = true
                cell.requestRemovedLbl.isHidden = false
            }
            
        }
        
        cell.HandleMessageBtn = {
            self.tabBarController?.selectedIndex = 0
        }
        
        return cell
    }
}

extension RequestVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
