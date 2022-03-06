//
//  EventDetailsViewController.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit
import SwiftUI
import SDWebImage
import GoogleMaps
import Alamofire
import ListPlaceholder
import GoogleMobileAds
import MapKit

class EventDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var imagesView: [UIImageView]!
    
    
    let eventImgCellId = "EventImageTableViewCell"
    let btnsCellId = "EventButtonsTableViewCell"
    let eventDateCellId = "EventDateAndTimeTableViewCell"
    let detailsCellId = "EventDetailsTableViewCell"
    let statisticsCellId = "EventStatisticsTableViewCell"
    let mapCellId = "EventMapTableViewCell"
    let attendeesCellId = "EventDetailsAttendeesTableViewCell"
    let adsCellId = "AdsTableViewCell"
    
    
    var eventId:String = ""
    var viewmodel:EventsViewModel = EventsViewModel()
    var joinVM:JoinEventViewModel = JoinEventViewModel()
    var leaveVM:LeaveEventViewModel = LeaveEventViewModel()
    var joinCahtEventVM:ChatViewModel = ChatViewModel()
    var attendeesVM:AttendeesViewModel = AttendeesViewModel()
    
    var locationTitle = ""
    var internetConect:Bool = false
    
    var visibleIndexPath:Int = 0
    var encryptedID:String = ""
    lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    var isConv:Bool = false
    
    var isEventAdmin: Bool = false
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    private let formatterTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    let viewX: UIView = {
        let viewX = UIView()
        viewX.bounds = CGRect(x: 0, y: 0, width: screenW, height: 200)
        viewX.backgroundColor = .red
        return viewX
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Friendzr Event"
        initOptionsEventButton()
        
        if isConv {
            initBackChatButton()
        }else {
            initBackButton()
        }
        
        setupViews()
        setupNavBar()
    
        CancelRequest.currentTask = false

        NotificationCenter.default.addObserver(self, selector: #selector(handleEventDetails), name: Notification.Name("handleEventDetails"), object: nil)
        
        pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Defaults.availableVC = "EventDetailsViewController"
        print("availableVC >> \(Defaults.availableVC)")
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }

    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
            loadEventDataDetails()
        case .wifi:
            internetConect = true
            loadEventDataDetails()
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    //MARK: - Helper
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        self.refreshControl.endRefreshing()
    }
    
    func HandleInternetConnection() {
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    func showNewtworkConnected() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            internetConect = false
            HandleInternetConnection()
        case .wwan:
            internetConect = true
        case .wifi:
            internetConect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    //MARK:- APIs
    @objc func handleEventDetails() {
        self.getEventDetails()
    }
    
    func getEventDetails() {
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now()) {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    func loadEventDataDetails() {
        self.hideView.isHidden = false
        self.hideView.showLoader()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            
            DispatchQueue.main.async {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
            }
        }
    }
    
    func setupViews() {
        tableView.register(UINib(nibName: eventImgCellId, bundle: nil), forCellReuseIdentifier: eventImgCellId)
        tableView.register(UINib(nibName: btnsCellId, bundle: nil), forCellReuseIdentifier: btnsCellId)
        tableView.register(UINib(nibName: eventDateCellId, bundle: nil), forCellReuseIdentifier: eventDateCellId)
        tableView.register(UINib(nibName: detailsCellId, bundle: nil), forCellReuseIdentifier: detailsCellId)
        tableView.register(UINib(nibName: statisticsCellId, bundle: nil), forCellReuseIdentifier: statisticsCellId)
        tableView.register(UINib(nibName: mapCellId, bundle: nil), forCellReuseIdentifier: mapCellId)
        tableView.register(UINib(nibName: attendeesCellId, bundle: nil), forCellReuseIdentifier: attendeesCellId)
        tableView.register(UINib(nibName: adsCellId, bundle: nil), forCellReuseIdentifier: adsCellId)
        
        for item in imagesView {
            item.cornerRadiusView(radius: 10)
        }
    }
}

extension EventDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.event.value?.key == 1 {
            return 8
        }else {
            return 7
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let JoinDate = self.formatterDate.string(from: Date())
        let Jointime = self.formatterTime.string(from: Date())
        

        let model = viewmodel.event.value
        
        if indexPath.row == 0 {//image
            guard let cell = tableView.dequeueReusableCell(withIdentifier: eventImgCellId, for: indexPath) as?  EventImageTableViewCell else {return UITableViewCell()}
            cell.eventImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.titleLbl.text = model?.title
            cell.categoryLbl.text = model?.categorie
            cell.attendeesLbl.text = "Attendees : ".localizedString + "\(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
            return cell
        }
        
        else if indexPath.row == 1 {//btns
            guard let cell = tableView.dequeueReusableCell(withIdentifier: btnsCellId, for: indexPath) as? EventButtonsTableViewCell else {return UITableViewCell()}
            
            cell.parentvc = self
            if model?.key == 1 { //my event
                cell.editBtn.isHidden = false
                cell.chatBtn.isHidden = false
                cell.joinBtn.isHidden = true
                cell.leaveBtn.isHidden = true
                self.isEventAdmin = true
            }else if model?.key == 2 { // not join
                cell.editBtn.isHidden = true
                cell.chatBtn.isHidden = true
                cell.joinBtn.isHidden = false
                cell.leaveBtn.isHidden = true
                self.isEventAdmin = false
            }else { // join
                cell.editBtn.isHidden = true
                cell.chatBtn.isHidden = false
                cell.joinBtn.isHidden = true
                cell.leaveBtn.isHidden = false
                self.isEventAdmin = false
            }
            
            cell.HandleChatBtn = {
                if model?.leveevent == 1 {
                    Router().toConversationVC(isEvent: true, eventChatID: self.eventId, leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: model?.image ?? "", titleChatName: model?.title ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1, isEventAdmin: self.isEventAdmin)
                }else {
                    self.view.makeToast("Wait, I'll join you in the event's chat...".localizedString)
                    self.joinCahtEventVM.joinChat(ByID: self.eventId, ActionDate: JoinDate, Actiontime: Jointime) { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            Router().toConversationVC(isEvent: true, eventChatID: self.eventId, leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: self.viewmodel.event.value?.image ?? "", titleChatName: self.viewmodel.event.value?.title ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1, isEventAdmin: self.isEventAdmin)
                        }
                    }
                }
            }
            
            cell.HandleLeaveBtn = {
                self.showNewtworkConnected()
                if self.internetConect == true {
                    cell.leaveBtn.isUserInteractionEnabled = false
                    self.leaveVM.leaveEvent(ByEventid: self.eventId,leaveeventDate: JoinDate,leaveeventtime: Jointime) { error, data in
                        DispatchQueue.main.async {
                            cell.leaveBtn.isUserInteractionEnabled = true
                        }
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        
                        DispatchQueue.main.async {
                            cell.leaveBtn.isUserInteractionEnabled = true
                        }
                        
                        NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
                    }
                }else {
                    return
                }
            }
            
            cell.HandleJoinBtn = {
                self.showNewtworkConnected()
                
                let JoinDate = self.formatterDate.string(from: Date())
                let Jointime = self.formatterTime.string(from: Date())
                
                if self.internetConect == true {
                    cell.joinBtn.isUserInteractionEnabled = false
                    self.joinVM.joinEvent(ByEventid: self.eventId,JoinDate:JoinDate ,Jointime:Jointime) { error, data in
                        DispatchQueue.main.async {
                            cell.joinBtn.isUserInteractionEnabled = true
                        }
                        
                        if let error = error {
                            self.hideLoading()
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
                    }
                }else {
                    return
                }
            }
            
            cell.HandleEditBtn = {
                self.showNewtworkConnected()
                if self.internetConect == true {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EditEventsVC") as? EditEventsVC else {return}
                    vc.eventModel = self.viewmodel.event.value
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    return
                }
            }
            
            return cell

        }
        
        else if indexPath.row == 2 {//date&time
            guard let cell = tableView.dequeueReusableCell(withIdentifier: eventDateCellId, for: indexPath) as? EventDateAndTimeTableViewCell else {return UITableViewCell()}
            
            cell.dateLbl.text = model?.datetext
            if model?.timefrom != "" && model?.allday == false {
                cell.timeLbl.text = model?.timetext
            }else {
                cell.timeLbl.text = "All Day".localizedString
            }
            return cell
        }
        
        else if indexPath.row == 3 {//desc
            guard let cell = tableView.dequeueReusableCell(withIdentifier: detailsCellId, for: indexPath) as? EventDetailsTableViewCell else {return UITableViewCell()}
            cell.detailsLbl.text = model?.descriptionEvent
            return cell
        }
        
        else if indexPath.row == 4 {//ads
            guard let cell = tableView.dequeueReusableCell(withIdentifier: adsCellId, for: indexPath) as? AdsTableViewCell else {return UITableViewCell()}
            cell.parentVC = self
            return cell
        }
        
        else if indexPath.row == 5 {//statistics
            guard let cell = tableView.dequeueReusableCell(withIdentifier: statisticsCellId, for: indexPath) as? EventStatisticsTableViewCell else {return UITableViewCell()}
            cell.parentvc = self
            cell.model = model
            cell.collectionView.reloadData()
            return cell
        }
        
        else if indexPath.row == 6 {//map
            guard let cell = tableView.dequeueReusableCell(withIdentifier: mapCellId, for: indexPath) as? EventMapTableViewCell else {return UITableViewCell()}
            
            cell.parentvc = self
            cell.model = model
            
            let lat = Double("\(model?.lat ?? "")")
            let lng = Double("\(model?.lang ?? "")")
            
            cell.setupGoogleMap(location: CLLocationCoordinate2D(latitude: lat ?? 0.0, longitude: lng ?? 0.0))
            cell.HandleDirectionBtn = {
                if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
                    UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(model?.lat ?? ""),\(model?.lang ?? "")&directionsmode=driving")!)
                }else {
                    let coordinates = CLLocationCoordinate2DMake(lat ?? 0.0, lng ?? 0.0)
                    let source = MKMapItem(coordinate: coordinates, name: "Source")
                    let regionDistance:CLLocationDistance = 10000
                    let destination = MKMapItem(coordinate: coordinates, name: model?.title ?? "")
                    let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                    let options = [
                        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                        ]
                    MKMapItem.openMaps(
                        with: [source, destination],
                        launchOptions: options
                    )
                }
            }
            return cell
        }
        
        else {//attendees
            guard let cell = tableView.dequeueReusableCell(withIdentifier: attendeesCellId, for: indexPath) as? EventDetailsAttendeesTableViewCell else {return UITableViewCell()}
            cell.parentvc = self
            cell.eventModel = model
            cell.tableView.reloadData()
            
            if model?.attendees?.count == 0 {
                cell.tableViewHeight.constant = 0
            }else if model?.attendees?.count == 1 {
                cell.tableViewHeight.constant = CGFloat(60)
            }else if model?.attendees?.count == 2 {
                cell.tableViewHeight.constant = CGFloat(160)
            }else {
                cell.tableViewHeight.constant = CGFloat(220)
            }
            
            return cell
        }
    }
}

extension EventDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = view.frame.height
        
        if indexPath.row == 0 {
            return height/3
        }else if indexPath.row == 1 {
            return 70
        }else if indexPath.row == 2 {
            return 100
        }else if indexPath.row == 3 {
            return 150
        }else if indexPath.row == 4 {//ads
            return UITableView.automaticDimension
        }else if indexPath.row == 5 {
            return 250
        }else if indexPath.row == 6 {
            return 200
        }else {
            return UITableView.automaticDimension
        }
    }
}

extension EventDetailsViewController {
    func initBackChatButton() {
        
        var imageName = ""
        imageName = "back_icon"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(backToConversationVC), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func backToConversationVC() {
        Router().toHome()
    }
    
    func initOptionsEventButton() {
        let imageName = "menu_H_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        if self.isEventAdmin {
            button.addTarget(self, action:  #selector(handleShareOptionsBtn), for: .touchUpInside)
        }else {
            button.addTarget(self, action:  #selector(handleEventOptionsBtn), for: .touchUpInside)
        }
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleEventOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    self.present(controller, animated: true)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.id = self.eventId
                    vc.isEvent = true
                    vc.selectedVC = "Present"
                    vc.reportType = 2
                    self.present(controller, animated: true)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }
        else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    self.present(controller, animated: true)
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.id = self.eventId
                    vc.isEvent = true
                    vc.selectedVC = "Present"
                    vc.reportType = 2
                    self.present(controller, animated: true)
                }
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }
    @objc func handleShareOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    self.present(controller, animated: true)
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }
        else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    self.present(controller, animated: true)
                }
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionSheet, animated: true, completion: nil)
        }
    }

    func shareEvent() {
        // Setting description
        let encryptedID = viewmodel.event.value?.encryptedID ?? ""
        let firstActivityItem = ""
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: "Friendzr//\(encryptedID)")!
        
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

extension EventDetailsViewController:GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Receive Ad")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
        bannerView.load(GADRequest())
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}
