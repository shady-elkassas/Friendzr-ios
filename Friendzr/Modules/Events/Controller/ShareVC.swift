//
//  ShareVC.swift
//  Friendzr
//
//  Created by Shady Elkassas on 18/01/2022.
//

import UIKit

class ShareVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var cellID = "ShareTableViewCell"
    
    var myFriendsVM:AllFriendesViewModel = AllFriendesViewModel()
    var myEventsVM:EventsViewModel = EventsViewModel()
    var encryptedID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Share".localizedString
        setupViews()
        getAllEvents(pageNumber: 1)
        getAllFriends(pageNumber: 1, search: "")
        initCloseBarButton()
        setupNavBar()
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName: cellID, bundle: nil), forHeaderFooterViewReuseIdentifier: cellID)
    }
    
    //MARK:- APIs
    func getAllEvents(pageNumber:Int) {
        myEventsVM.getMyEvents(pageNumber: pageNumber)
        myEventsVM.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        myEventsVM.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    
    func getAllFriends(pageNumber:Int,search:String) {
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
                self.showAlert(withMessage: error)
            }
        }
    }
    
    
    func shareEvent() {
        // Setting description
        let firstActivityItem = "https://friendzr.com/"
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: "friendzr://\(encryptedID)")!

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
}

extension ShareVC:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return myFriendsVM.friends.value?.data?.count ?? 0
        }else {
            return myEventsVM.events.value?.data?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ShareTableViewCell else {return UITableViewCell()}

        if indexPath.section == 0 {
            cell.titleLbl.text = "Share in any application".localizedString
            cell.titleLbl.font = UIFont(name: "Montserrat-Bold", size: 15)
            cell.sendBtn.isHidden = true
            cell.bottomView.isHidden = true
            cell.titleLbl.textColor = UIColor.FriendzrColors.primary!
            cell.containerView.backgroundColor = .clear
        }
        else if indexPath.section == 1 {
            let friendsModel = myFriendsVM.friends.value?.data?[indexPath.row]
            cell.titleLbl.text = friendsModel?.userName
            cell.sendBtn.isHidden = false
            cell.bottomView.isHidden = false
            cell.titleLbl.textColor = .darkGray
            cell.titleLbl.font = UIFont(name: "Montserrat-Medium", size: 12)
            cell.containerView.backgroundColor = .clear
        }
        else {
            let eventsModel = myEventsVM.events.value?.data?[indexPath.row]
            cell.titleLbl.text = eventsModel?.title
            cell.sendBtn.isHidden = false
            cell.bottomView.isHidden = false
            cell.titleLbl.textColor = .darkGray
            cell.titleLbl.font = UIFont(name: "Montserrat-Medium", size: 12)
            cell.containerView.backgroundColor = .clear
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: cellID) as! ShareTableViewCell
        
        if section == 1 {
            headerCell.titleLbl.text = "My Friends".localizedString
            headerCell.titleLbl.textColor = .black
            headerCell.titleLbl.font = UIFont(name: "Montserrat-Bold", size: 15)
            headerCell.bottomView.isHidden = true
            headerCell.sendBtn.isHidden = true
            headerCell.containerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            headerCell.containerView.cornerRadiusView(radius: 8)
            return headerCell
        }
        else if section == 2 {
            headerCell.titleLbl.text = "My Events".localizedString
            headerCell.titleLbl.textColor = .black
            headerCell.titleLbl.font = UIFont(name: "Montserrat-Bold", size: 15)
            headerCell.bottomView.isHidden = true
            headerCell.sendBtn.isHidden = true
            headerCell.containerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            headerCell.containerView.cornerRadiusView(radius: 8)
            return headerCell
        }
        else {
            return UIView()
        }
    }
}


extension ShareVC :UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 55
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            shareEvent()
        }else {
            return
        }
    }
}
