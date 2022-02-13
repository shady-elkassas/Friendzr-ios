//
//  ShareVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 18/01/2022.
//

import UIKit

class ShareVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cellID = "ShareTableViewCell"
    
    var myGroupCellId = "GroupsShareTableViewCell"
    var myEventsCellId = "EventsShareTableViewCell"
    var myFriendsCellId = "FriendsShareTableViewCell"
    
    var myFriendsVM:AllFriendesViewModel = AllFriendesViewModel()
    var myEventsVM:EventsViewModel = EventsViewModel()
    var myGroupsVM:GroupViewModel = GroupViewModel()
    
    var encryptedID:String = ""
    var isSearch:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Share".localizedString
        setupViews()
        getAllMyEvents(pageNumber: 1)
        getAllMyGroups(pageNumber: 1, search: "")
        getAllMyFriends(pageNumber: 1, search: "")
        initCloseBarButton()
        setupNavBar()
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: myGroupCellId, bundle: nil), forCellReuseIdentifier: myGroupCellId)
        tableView.register(UINib(nibName: myEventsCellId, bundle: nil), forCellReuseIdentifier: myEventsCellId)
        tableView.register(UINib(nibName: myFriendsCellId, bundle: nil), forCellReuseIdentifier: myFriendsCellId)
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    //MARK:- APIs
    func getAllMyEvents(pageNumber:Int) {
        myEventsVM.getMyEvents(pageNumber: pageNumber)
        myEventsVM.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        myEventsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    func getAllMyGroups(pageNumber:Int,search:String) {
        myGroupsVM.getAllGroupChat(pageNumber: pageNumber, search: search)
        myGroupsVM.listChat.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        myGroupsVM.errorMsg.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    func getAllMyFriends(pageNumber:Int,search:String) {
        myFriendsVM.getAllFriendes(pageNumber: pageNumber, search: search)
        myFriendsVM.friends.bind { [unowned self] value in
            DispatchQueue.main.async {
                tableView.hideLoader()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        myFriendsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    func shareEvent() {
        // Setting description
        let firstActivityItem = "https://friendzr.com/about-us/"
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: firstActivityItem)!
        
        // If you want to use an image
        let image : UIImage = UIImage(named: "Share_ic")!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = activityViewController.view
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections =  UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func OnFriendsSearchCallBack(_ data: String, _ value: Bool) -> () {
        print(data, value)
        isSearch = value
        
        if value == true {
            getAllMyFriends(pageNumber: 1, search: data)
        }else {
            getAllMyFriends(pageNumber: 1, search: "")
        }
    }
    
    func OnEventsSearchCallBack(_ data: String, _ value: Bool) -> () {
        print(data, value)
        isSearch = value

        if value == true {
            //            getAllMyEvents(pageNumber: 1)
        }else {
            //            getAllMyEvents(pageNumber: 1)
        }
    }
    
    func OnGroupsSearchCallBack(_ data: String, _ value: Bool) -> () {
        print(data, value)
        isSearch = value
        if value == true {
            getAllMyGroups(pageNumber: 1, search: data)
        }else {
            getAllMyGroups(pageNumber: 1, search: "")
        }
    }
}

extension ShareVC:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearch {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
                cell.titleLbl.text = "Share Outside Friendzr".localizedString
                cell.titleLbl.font = UIFont(name: "Montserrat-Bold", size: 15)
                cell.sendBtn.isHidden = true
                cell.bottomView.isHidden = true
                cell.titleLbl.textColor = UIColor.FriendzrColors.primary!
                cell.containerView.backgroundColor = .clear
                return cell
            }
            else if indexPath.row == 1 {//friends
                guard let cell = tableView.dequeueReusableCell(withIdentifier: myFriendsCellId, for: indexPath) as? FriendsShareTableViewCell else {return UITableViewCell()}
                cell.myFriendsModel = myFriendsVM.friends.value?.data
                
                cell.parentVC = self
                cell.tableView.reloadData()
                
                cell.onSearchFriendsCallBackResponse = self.OnFriendsSearchCallBack
                
                if myFriendsVM.friends.value?.data?.count == 0 {
                    cell.emptyView.isHidden = false
                    cell.emptyLbl.text = "No friends match your search"
                }else {
                    cell.emptyView.isHidden = true
                }
                
                cell.HandleSearchBtn = {
                    cell.searchContainerView.isHidden = false
                }
                
                return cell
            }
            else if indexPath.row == 2 {//groups
                guard let cell = tableView.dequeueReusableCell(withIdentifier: myGroupCellId, for: indexPath) as? GroupsShareTableViewCell else {return UITableViewCell()}
                cell.myGroupsModel = myGroupsVM.listChat.value?.data
                
                cell.onSearchGroupsCallBackResponse = self.OnGroupsSearchCallBack
                if myGroupsVM.listChat.value?.data?.count == 0 {
                    cell.emptyView.isHidden = false
                    cell.emptyLbl.text = "No groups match your search"
                }else {
                    cell.emptyView.isHidden = true
                }
                cell.parentVC = self
                cell.tableView.reloadData()
                
                return cell
            }else {//events
                guard let cell = tableView.dequeueReusableCell(withIdentifier: myEventsCellId, for: indexPath) as? EventsShareTableViewCell else {return UITableViewCell()}
                cell.myEventsModel = myEventsVM.events.value?.data
                cell.onSearchEventsCallBackResponse = self.OnEventsSearchCallBack
                if myEventsVM.events.value?.data?.count == 0 {
                    cell.emptyView.isHidden = false
                    cell.emptyLbl.text = "No Events match your search"
                }else {
                    cell.emptyView.isHidden = true
                }
                cell.parentVC = self
                cell.tableView.reloadData()
                return cell
            }
        }
        
        else {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}
                cell.titleLbl.text = "Share Outside Friendzr".localizedString
                cell.titleLbl.font = UIFont(name: "Montserrat-Bold", size: 15)
                cell.sendBtn.isHidden = true
                cell.bottomView.isHidden = true
                cell.titleLbl.textColor = UIColor.FriendzrColors.primary!
                cell.containerView.backgroundColor = .clear
                return cell
            }
            else if indexPath.row == 1 {//friends
                guard let cell = tableView.dequeueReusableCell(withIdentifier: myFriendsCellId, for: indexPath) as? FriendsShareTableViewCell else {return UITableViewCell()}
                cell.myFriendsModel = myFriendsVM.friends.value?.data
                
                if myFriendsVM.friends.value?.data?.count == 0 {
                    cell.emptyView.isHidden = false
                    cell.searchContainerView.isHidden = true
                }else {
                    cell.emptyView.isHidden = true
                    cell.searchContainerView.isHidden = false
                }
                
                cell.parentVC = self
                cell.tableView.reloadData()
                
                cell.onSearchFriendsCallBackResponse = self.OnFriendsSearchCallBack
                
                cell.HandleSearchBtn = {
                    cell.searchContainerView.isHidden = false
                }
                
                return cell
            }
            else if indexPath.row == 2 {//groups
                guard let cell = tableView.dequeueReusableCell(withIdentifier: myGroupCellId, for: indexPath) as? GroupsShareTableViewCell else {return UITableViewCell()}
                cell.myGroupsModel = myGroupsVM.listChat.value?.data
                
                if myGroupsVM.listChat.value?.data?.count == 0 {
                    cell.emptyView.isHidden = false
                    cell.searchContainerView.isHidden = true
                }else {
                    cell.emptyView.isHidden = true
                    cell.searchContainerView.isHidden = false
                }
                
                cell.onSearchGroupsCallBackResponse = self.OnGroupsSearchCallBack
                
                cell.parentVC = self
                cell.tableView.reloadData()
                
                return cell
            }else {//events
                guard let cell = tableView.dequeueReusableCell(withIdentifier: myEventsCellId, for: indexPath) as? EventsShareTableViewCell else {return UITableViewCell()}
                cell.myEventsModel = myEventsVM.events.value?.data
                if myEventsVM.events.value?.data?.count == 0 {
                    cell.emptyView.isHidden = false
                    cell.searchContainerView.isHidden = true
                }else {
                    cell.emptyView.isHidden = true
                    cell.searchContainerView.isHidden = false
                }
                
                cell.onSearchEventsCallBackResponse = self.OnEventsSearchCallBack
                cell.parentVC = self
                cell.tableView.reloadData()
                return cell
            }
        }

    }
}


extension ShareVC :UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.frame.height
        if indexPath.row == 0 {
            return 45
        }
        else if indexPath.row == 1 {
            if myFriendsVM.friends.value?.data?.count == 0 {
                return height/3.2
            }else {
                return height/2.5
            }
            
        }
        else if indexPath.row == 2 {
            if myGroupsVM.listChat.value?.data?.count == 0 {
                return height/3.2
            }else {
                return height/2.5
            }
        }
        else {
            if myEventsVM.events.value?.data?.count == 0 {
                return height/3.2
            }else {
                return height/2.5
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            shareEvent()
        }else {
            return
        }
    }
}
