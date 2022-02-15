//
//  MyProfileViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 14/02/2022.
//

import UIKit
import SDWebImage
import ListPlaceholder

class MyProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!

    var viewmodel: ProfileViewModel = ProfileViewModel()
    var internetConnection:Bool = false
    
    let imageCellID = "ImageProfileTableViewCell"
    let userNameCellId = "ProfileUserNameTableViewCell"
    let interestsCellId = "InterestsProfileTableViewCell"
    let bestDescribesCellId = "BestDescribesTableViewCell"
    let aboutmeCellId = "AboutMeTableViewCell"
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        self.title = "My Profile".localizedString
        initBackButton()
        clearNavigationBar()
        setupView()
        
        tableView.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CancelRequest.currentTask = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CancelRequest.currentTask = true
        hideView.hideLoader()
    }
    
    
    @objc func didPullToRefresh() {
        print("Refersh")
        updateUserInterface()
        self.refreshControl.endRefreshing()
    }
    
    //MARK: - API
    func getProfileInformation() {
        self.hideView.showLoader()
        viewmodel.getProfileInfo()
        viewmodel.userModel.bind { [unowned self]value in
            DispatchQueue.main.async {
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }

                DispatchQueue.main.async {
                    self.tableView.dataSource = self
                    self.tableView.delegate = self
                    self.tableView.reloadData()
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            self.hideLoading()
            DispatchQueue.main.async {
                self.hideLoading()
                if error == "Internal Server Error" {
                    HandleInternetConnection()
                }else {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                }
            }
        }
    }
    
    //MARK: - Helper
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnection = false
            HandleInternetConnection()
        case .wwan:
            internetConnection = true
            getProfileInformation()
        case .wifi:
            internetConnection = true
            getProfileInformation()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func updateUserInterfaceBtns() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConnection = false
        case .wwan:
            internetConnection = true
            getProfileInformation()
        case .wifi:
            internetConnection = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("No available network, please try again!".localizedString)
    }
    
    func setupView() {
        tableView.register(UINib(nibName: imageCellID, bundle: nil), forCellReuseIdentifier: imageCellID)
        tableView.register(UINib(nibName: userNameCellId, bundle: nil), forCellReuseIdentifier: userNameCellId)
        tableView.register(UINib(nibName: interestsCellId, bundle: nil), forCellReuseIdentifier: interestsCellId)
        tableView.register(UINib(nibName: bestDescribesCellId, bundle: nil), forCellReuseIdentifier: bestDescribesCellId)
        tableView.register(UINib(nibName: aboutmeCellId, bundle: nil), forCellReuseIdentifier: aboutmeCellId)
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 10)
        }
    }

}

extension MyProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewmodel.userModel.value
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: imageCellID, for: indexPath) as? ImageProfileTableViewCell else {return UITableViewCell()}
            
            cell.profileImg.sd_setImage(with: URL(string: model?.userImage ?? "" ), placeholderImage: UIImage(named: "placeholder"))
            cell.ageLbl.text = "\(model?.age ?? 0)"
            if model?.gender == "other" {
                cell.genderlbl.text = "other(".localizedString + "\(model?.otherGenderName ?? "")" + ")"
            }else {
                cell.genderlbl.text = model?.gender
            }
            
            cell.HandleEditBtn = {
                self.updateUserInterfaceBtns()
                if self.internetConnection {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "EditMyProfileVC") as? EditMyProfileVC else {return}
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    return
                }
            }
            
            return cell
        }
        else if indexPath.row == 1 {//name & username
            guard let cell = tableView.dequeueReusableCell(withIdentifier: userNameCellId, for: indexPath) as? ProfileUserNameTableViewCell else {return UITableViewCell()}
            cell.userNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.nameLbl.text = model?.userName
            return cell
        }
        else if indexPath.row == 2 {//interests
            guard let cell = tableView.dequeueReusableCell(withIdentifier: interestsCellId, for: indexPath) as? InterestsProfileTableViewCell else {return UITableViewCell()}
            cell.tagsListView.removeAllTags()
            if (model?.listoftagsmodel?.count ?? 0) > 4 {
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[0].tagID ?? "", title: model?.listoftagsmodel?[0].tagname ?? "")
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[1].tagID ?? "", title: model?.listoftagsmodel?[1].tagname ?? "")
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[2].tagID ?? "", title: model?.listoftagsmodel?[2].tagname ?? "")
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[3].tagID ?? "", title: model?.listoftagsmodel?[3].tagname ?? "")
            }else {
                for item in model?.listoftagsmodel ?? [] {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#\(item.tagname)")
                }
            }

            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            
            return cell
        }
        else if indexPath.row == 3 {//what best describes me
            guard let cell = tableView.dequeueReusableCell(withIdentifier: bestDescribesCellId, for: indexPath) as? BestDescribesTableViewCell else {return UITableViewCell()}
            
            cell.tagsListView.removeAllTags()
            if (model?.listoftagsmodel?.count ?? 0) > 4 {
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[0].tagID ?? "", title: model?.listoftagsmodel?[0].tagname ?? "")
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[1].tagID ?? "", title: model?.listoftagsmodel?[1].tagname ?? "")
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[2].tagID ?? "", title: model?.listoftagsmodel?[2].tagname ?? "")
                cell.tagsListView.addTag(tagId: model?.listoftagsmodel?[3].tagID ?? "", title: model?.listoftagsmodel?[3].tagname ?? "")
            }else {
                for item in model?.listoftagsmodel ?? [] {
                    cell.tagsListView.addTag(tagId: item.tagID, title: "#\(item.tagname)")
                }
            }

            print("tagListView.rows \(cell.tagsListView.rows)")
            cell.tagsListViewHeight.constant = CGFloat(cell.tagsListView.rows * 25)
            
            if cell.tagsListView.rows == 1 {
                cell.tagsTopConstraint.constant = 10
                cell.tagsBottomConstraint.constant = 16
            }else if cell.tagsListView.rows == 2 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 26
            }else if cell.tagsListView.rows == 3 {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 40
            }else {
                cell.tagsTopConstraint.constant = 12
                cell.tagsBottomConstraint.constant = 46
            }
            return cell
        }
        else if indexPath.row == 4 {//more about me...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: aboutmeCellId, for: indexPath) as? AboutMeTableViewCell else {return UITableViewCell()}
            cell.aboutMeLbl.text = model?.bio
            cell.titleLbl.text = "More about me..."
            return cell
            
        }
        else {//what I am looking for...
            guard let cell = tableView.dequeueReusableCell(withIdentifier: aboutmeCellId, for: indexPath) as? AboutMeTableViewCell else {return UITableViewCell()}
            cell.aboutMeLbl.text = model?.bio
            cell.titleLbl.text = "What am I looking for..."
            return cell
        }
    }
}

extension MyProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.bounds.height
        
        if indexPath.row == 0 {
            return height/2.5
        }
        else {
            return UITableView.automaticDimension
        }
    }
}
