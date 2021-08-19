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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        initProfileBarButton()
        setup()
        initSwitchBarButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    //MARK: - Helper
    func setup() {
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

//MARK: - Extensions
extension FeedVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? FeedsTableViewCell else {return UITableViewCell()}
        
        cell.HandleRequestSentBtn = {
            cell.requestSentBtn.isHidden = true
            cell.sendRequestBtn.isHidden = false
        }
        
        cell.HandleSendRequestBtn = {
            cell.requestSentBtn.isHidden = false
            cell.sendRequestBtn.isHidden = true
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
