//
//  FeedVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit

class FeedVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let cellID = "FeedsTableViewCell"
    var viewmodel:FeedViewModel = FeedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    
    var refreshControl = UIRefreshControl()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        initProfileBarButton()
        setup()
        initSwitchBarButton()
        pullToRefresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        getAllFeeds()
    }
    
    
    //MARK:- APIs
    func getAllFeeds() {
        self.showLoading()
        viewmodel.getAllUsers()
        viewmodel.feeds.bind { [unowned self] value in
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
    
    //MARK: - Helper
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        getAllFeeds()
        self.refreshControl.endRefreshing()
    }
    
    func setup() {
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

//MARK: - Extensions
extension FeedVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.feeds.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? FeedsTableViewCell else {return UITableViewCell()}
        let model = viewmodel.feeds.value?[indexPath.row]
        cell.friendRequestNameLbl.text = model?.userName
        cell.friendRequestUserNameLbl.text = model?.displayedUserName
        cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "avatar"))
        
        //status key
        switch model?.key {
        case 0:
            //Status = normal case
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = false
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 1:
            //Status = I have added a friend request
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = false
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 2:
            //Status = Send me a request to add a friend
            cell.respondBtn.isHidden = false
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 3:
            //Status = We are friends
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = false
            cell.unblockBtn.isHidden = true
            break
        case 4:
            //Status = I block user
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = false
            break
        case 5:
            //Status = user block me
            cell.respondBtn.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.stackBtnsView.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 6:
            break
        default:
            break
        }
        
        cell.HandleSendRequestBtn = { //send request
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                self.getAllFeeds()
            }
        }
        
        cell.HandleRespondBtn = { //respond request
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                self.getAllFeeds()
            }
        }
        
        cell.HandleBlockBtn = { //block account
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 3) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                self.getAllFeeds()
            }
        }
        
        cell.HandleUnblocktBtn = { //unblock account
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 4) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                self.getAllFeeds()
            }
        }
        
        
        cell.HandleUnfreiendBtn = { //unfriend account
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 5) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                self.getAllFeeds()
            }
        }
        
        cell.HandleCancelRequestBtn = { // cancel request
            self.showLoading()
            self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                self.hideLoading()
                if let error = error {
                    self.showAlert(withMessage: error)
                    return
                }
                
                guard let message = message else {return}
                self.showAlert(withMessage: message)
                self.getAllFeeds()
            }
        }
        
        return cell
    }
}

extension FeedVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
        vc.userID = viewmodel.feeds.value?[indexPath.row].userId ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FeedVC {
    func initSwitchBarButton() {
        let button = UISwitch()
        button.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        button.onTintColor = UIColor.FriendzrColors.primary
        button.thumbTintColor = .white
        button.addTarget(self, action: #selector(handleSwitchBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleSwitchBtn() {
    }
}
