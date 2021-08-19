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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Request"
        setupNavBar()
        initProfileBarButton()
    }
    
    //MARK: - Helper
    func setup() {
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
}

//MARK: - Extensions
extension RequestVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? RequestTableViewCell else {return UITableViewCell()}
        
        cell.HandleAcceptBtn = {
            cell.stackViewBtns.isHidden = true
            cell.messageBtn.isHidden = false
        }
        
        cell.HandleDeleteBtn = {
            cell.stackViewBtns.isHidden = true
            cell.messageBtn.isHidden = true
            cell.requestRemovedLbl.isHidden = false
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
