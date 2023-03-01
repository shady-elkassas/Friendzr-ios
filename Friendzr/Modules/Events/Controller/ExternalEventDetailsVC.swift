//
//  ExternalEventDetailsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 27/03/2022.
//

import UIKit
import SwiftUI
import SDWebImage
import GoogleMaps
import Alamofire
import ListPlaceholder
import ImageSlideshow
import MapKit
import Network

class ExternalEventDetailsVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var imagesView: [UIImageView]!
    
    //MARK: - Properties
    let eventImgCellId = "ExternalImageTableViewCell"
    let btnsCellId = "EventButtonsTableViewCell"
    let eventDateCellId = "EventDateAndTimeTableViewCell"
    let detailsCellId = "EventDetailsTableViewCell"
    let statisticsCellId = "StatisticsDetailsTableViewCell"
    let mapCellId = "EventMapTableViewCell"
    let attendeesCellId = "EventDetailsAttendeesTableViewCell"
    let adsCellId = "AdsTableViewCell"
    
    var eventId:String = ""
    var viewmodel:EventsViewModel = EventsViewModel()
    var joinVM:JoinEventViewModel = JoinEventViewModel()
    var leaveVM:LeaveEventViewModel = LeaveEventViewModel()
    var joinCahtEventVM:ChatViewModel = ChatViewModel()
    var attendeesVM:AttendeesViewModel = AttendeesViewModel()
    
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    var locationTitle = ""
    //    var internetConect:Bool = false
    
    var visibleIndexPath:Int = 0
    var encryptedID:String = ""
    lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    var isConv:Bool = false
    var inMap:Bool = false
    
    var myString:String = ""
    var myMutableString = NSMutableAttributedString()
    
    var isEventAdmin: Bool = false
    var selectedVC:Bool = false
    var isprivateEvent:Bool = false
    var eventHasExpired:Bool = false

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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedVC {
            initCloseBarButton()
        }else {
            initBackButton()
        }
        
        self.title = "External Event"
        
        setupViews()
        CancelRequest.currentTask = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleExternalEventDetails), name: Notification.Name("handleExternalEventDetails"), object: nil)
        
        pullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if inMap {
            Defaults.availableVC = "MapVC"
        }else {
            if selectedVC {
                Defaults.availableVC = "PresentEventDetailsViewController"
            }else {
                Defaults.availableVC = "EventDetailsViewController"
            }
        }
        
        print("availableVC >> \(Defaults.availableVC)")
        hideNavigationBar(NavigationBar: false, BackButton: false)
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    //MARK: - Helper
    func setupViews() {
        tableView.register(UINib(nibName: eventImgCellId, bundle: nil), forCellReuseIdentifier: eventImgCellId)
        tableView.register(UINib(nibName: btnsCellId, bundle: nil), forCellReuseIdentifier: btnsCellId)
        tableView.register(UINib(nibName: eventDateCellId, bundle: nil), forCellReuseIdentifier: eventDateCellId)
        tableView.register(UINib(nibName: detailsCellId, bundle: nil), forCellReuseIdentifier: detailsCellId)
        tableView.register(UINib(nibName: statisticsCellId, bundle: nil), forCellReuseIdentifier: statisticsCellId)
        tableView.register(UINib(nibName: mapCellId, bundle: nil), forCellReuseIdentifier: mapCellId)
        tableView.register(UINib(nibName: adsCellId, bundle: nil), forCellReuseIdentifier: adsCellId)
        
        for item in imagesView {
            item.cornerRadiusView(radius: 10)
        }
    }
    
    
    
    func onShowconfirmCallBack(_ back: Bool) -> () {
        if back == true {
            self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            self.alertView?.titleLbl.text = "Confirm?".localizedString
            self.alertView?.detailsLbl.text = "Have you completed the form and booked tickets?".localizedString
            
            self.alertView?.HandleConfirmBtn = {
                if NetworkConected.internetConect == true {
                    self.joinExternalEvent()
                }
                
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
            
            self.view.addSubview((self.alertView)!)
        }
    }
    
    //change title for any btns
    func changeTitleBtns(btn:UIButton,title:String) {
        btn.setTitle(title, for: .normal)
    }
    
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
    
    //MARK: - APIs
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.loadEventDataDetails()
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.loadEventDataDetails()
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    @objc func handleExternalEventDetails() {
        self.getEventDetails()
    }
    
    func getEventDetails() {
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now()) {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.async {
                    if value.key == 1 {
                        self?.isEventAdmin = true
                    }else {
                        self?.isEventAdmin = false
                    }
                    
                    if value.eventHasExpired {
                        self?.eventHasExpired = true
                    }else {
                        self?.eventHasExpired = false
                        self?.initOptionsEventButton()
                    }
                    
                }
                
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    
    func loadEventDataDetails() {
        self.hideView.isHidden = false
        self.hideView.showLoader()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [weak self] value in
            
            DispatchQueue.main.async {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self?.hideView.hideLoader()
                    self?.hideView.isHidden = true
                }
                
                DispatchQueue.main.async {
                    if value.key == 1 {
                        self?.isEventAdmin = true
                    }else {
                        self?.isEventAdmin = false
                    }
                    
                    if value.eventHasExpired {
                        self?.eventHasExpired = true
                    }else {
                        self?.eventHasExpired = false
                        self?.initOptionsEventButton()
                    }
                }
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self?.view.makeToast(error)
                }
            }
        }
    }
    
    func setupSliderShow(_ cell: ExternalImageTableViewCell, _ model: EventObj?) {
//        cell.imagesSlider.slideshowInterval = 5.0
        cell.imagesSlider.pageIndicatorPosition = .init(horizontal: .center, vertical: .top)
        cell.imagesSlider.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        cell.imagesSlider.activityIndicator = DefaultActivityIndicator()
        cell.imagesSlider.delegate = self
        
        //        imagesSlider.setImageInputs(localSource)
        
        if model?.image != "" {
            cell.imagesSlider.setImageInputs([SDWebImageSource(urlString: model?.image ?? "") ?? SDWebImageSource(urlString: placeholderString)!])
        }else {
            cell.imagesSlider.setImageInputs(placeholderLocalSource)
        }
    }
}

extension ExternalEventDetailsVC: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}

//MARK: - UITableViewDataSource
extension ExternalEventDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let JoinDate = self.formatterDate.string(from: Date())
        let Jointime = self.formatterTime.string(from: Date())
        
        
        let model = viewmodel.event.value
        
        if indexPath.row == 0 {//image
            guard let cell = tableView.dequeueReusableCell(withIdentifier: eventImgCellId, for: indexPath) as?  ExternalImageTableViewCell else {return UITableViewCell()}

            cell.titleLbl.text = model?.title
            cell.parentVC = self
            
            setupSliderShow(cell, model)

            return cell
        }
        
        else if indexPath.row == 1 {//btns
            guard let cell = tableView.dequeueReusableCell(withIdentifier: btnsCellId, for: indexPath) as? EventButtonsTableViewCell else {return UITableViewCell()}
            
            cell.parentvc = self
            cell.bottomLbl.isHidden = false
            
            statusEvent(model, cell)
            
            cell.HandleChatBtn = {
                self.handleEventChat(model, JoinDate, Jointime)
            }
            
            cell.HandleLeaveBtn = {
                if NetworkConected.internetConect == true {
                    self.leaveEvent(cell, JoinDate, Jointime)
                }
                else {
                    return
                }
            }
            
            cell.HandleJoinBtn = {
                if model?.checkout_details != nil || model?.checkout_details != "" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventWebNC") as? UINavigationController, let vc = controller.viewControllers.first as? ExternalEventWebView {
                        vc.urlString = (model?.checkout_details ?? "").replacingOccurrences(of: "\'", with: "", options: NSString.CompareOptions.literal, range: nil)
                        vc.onShowconfirmCallBackResponse = self.onShowconfirmCallBack
                        self.present(controller, animated: true)
                    }
                }
                else {
                    self.joinEvent(cell,JoinDate, Jointime)
                }
            }
            
            cell.HandleEditBtn = {
                
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
            
            if model?.descriptionEvent != "" {
                if (model?.descriptionEvent?.count ?? 0) > 180 {
                    DispatchQueue.main.async {
                        cell.detailsLbl.addTrailing(with: "... ", moreText: "Read more", moreTextFont: UIFont(name: "Montserrat-Medium", size: 12)!, moreTextColor: UIColor.FriendzrColors.primary!)
                    }
                }
            }
            
            return cell
        }
        
        else if indexPath.row == 4 {//ads
            guard let cell = tableView.dequeueReusableCell(withIdentifier: adsCellId, for: indexPath) as? AdsTableViewCell else {return UITableViewCell()}
            cell.parentVC = self
            cell.setupAds()
            return cell
        }
        
        else if indexPath.row == 5 {//statistics
            guard let cell = tableView.dequeueReusableCell(withIdentifier: statisticsCellId, for: indexPath) as? StatisticsDetailsTableViewCell else {return UITableViewCell()}
            
            cell.titleView.isHidden = false
            cell.titleViewHeight.constant = 35
            cell.bottomTitleViewLayoutConstraint.constant = 0
            cell.titleView.setCornerforTop()
            cell.containerView.setCornerforBottom()
            
            statisticsEvent(cell, model)
            
            return cell
        }
        
        else {//map
            guard let cell = tableView.dequeueReusableCell(withIdentifier: mapCellId, for: indexPath) as? EventMapTableViewCell else {return UITableViewCell()}
            
            cell.parentvc = self
            cell.model = model
            
            let lat = Double("\(model?.lat ?? "")") ?? 0.0
            let lng = Double("\(model?.lang ?? "")") ?? 0.0
            
            cell.setupGoogleMap(location: CLLocationCoordinate2D(latitude: lat , longitude: lng))
            cell.HandleDirectionBtn = {
                self.directionEventInMap(model, lat, lng)
            }
            return cell
        }
    }
}

//MARK: - UITableViewDelegate && UIPopoverPresentationControllerDelegate
extension ExternalEventDetailsVC: UITableViewDelegate,UIPopoverPresentationControllerDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return screenH/3
        }else if indexPath.row == 1 {
            return UITableView.automaticDimension
        }else if indexPath.row == 2 {
            return 100
        }else if indexPath.row == 3 {
            return 150
        }else if indexPath.row == 4 {//ads
            if Defaults.isSubscribe == false {
                return UITableView.automaticDimension
            }else {
                return 0
            }
        }else if indexPath.row == 5 {
            return 290
        }else {
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewmodel.event.value
//        if indexPath.row == 0 {
//            guard let popupVC = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ShowImageVC") as? ShowImageVC else {return}
//            popupVC.modalPresentationStyle = .overCurrentContext
//            popupVC.modalTransitionStyle = .crossDissolve
//            let pVC = popupVC.popoverPresentationController
//            pVC?.permittedArrowDirections = .any
//            pVC?.delegate = self
//            pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
//            popupVC.imgURL = model?.image
//            present(popupVC, animated: true, completion: nil)
//        }
//        else
        if indexPath.row == 3 {
            if (model?.descriptionEvent?.count ?? 0) > 180 {
                guard let popupVC = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExpandDescriptionVC") as? ExpandDescriptionVC else {return}
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = .crossDissolve
                let pVC = popupVC.popoverPresentationController
                pVC?.permittedArrowDirections = .any
                pVC?.delegate = self
                pVC?.sourceRect = CGRect(x: 100, y: 100, width: 1, height: 1)
                popupVC.myString = model?.descriptionEvent ?? ""
                present(popupVC, animated: true, completion: nil)
            }
        }
    }
}

extension ExternalEventDetailsVC {
    
    // init Options Event Button
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
            if isprivateEvent {
                button.addTarget(self, action:  #selector(handleEventReportBtn), for: .touchUpInside)
            }else {
                button.addTarget(self, action:  #selector(handleEventOptionsBtn), for: .touchUpInside)
            }
        }
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    @objc func handleEventOptionsBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
            if self.viewmodel.event.value?.eventTypeName == "Private" {
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SharePrivateEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? SharePrivateEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    self.present(controller, animated: true)
                }
            }else {
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    vc.eventname = self.viewmodel.event.value?.title ?? ""
                    vc.encryptedID = self.viewmodel.event.value?.encryptedID ?? ""
                    vc.eventimage = self.viewmodel.event.value?.image ?? ""
                    vc.eventDesc = self.viewmodel.event.value?.descriptionEvent ?? ""
                    self.present(controller, animated: true)
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                vc.id = self.eventId
                vc.isEvent = true
                vc.selectedVC = "PresentC"
                vc.reportType = 2
                self.present(controller, animated: true)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    @objc func handleEventReportBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
            if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                vc.id = self.eventId
                vc.isEvent = true
                vc.selectedVC = "PresentC"
                vc.reportType = 2
                self.present(controller, animated: true)
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    @objc func handleShareOptionsBtn() {
        let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
            if self.viewmodel.event.value?.eventTypeName == "Private" {
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SharePrivateEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? SharePrivateEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    self.present(controller, animated: true)
                }
            }else {
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                    vc.eventID = self.viewmodel.event.value?.id ?? ""
                    vc.eventname = self.viewmodel.event.value?.title ?? ""
                    vc.encryptedID = self.viewmodel.event.value?.encryptedID ?? ""
                    vc.eventimage = self.viewmodel.event.value?.image ?? ""
                    vc.eventDesc = self.viewmodel.event.value?.descriptionEvent ?? ""
                    self.present(controller, animated: true)
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
        }))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
}


extension ExternalEventDetailsVC {
    func joinExternalEvent() {
        let JoinDate = self.formatterDate.string(from: Date())
        let Jointime = self.formatterTime.string(from: Date())
        
        if NetworkConected.internetConect == true {
            self.joinVM.joinEvent(ByEventid: self.eventId,JoinDate:JoinDate ,Jointime:Jointime) { error, data in
                
                
                if let error = error {
                    self.hideLoading()
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("handleExternalEventDetails"), object: nil, userInfo: nil)
                }
            }
        }
    }
    
    func joinEvent(_ cell: EventButtonsTableViewCell, _ JoinDate: String, _ Jointime: String) {
        self.changeTitleBtns(btn: cell.joinBtn, title: "Joining...".localizedString)
        cell.joinBtn.isUserInteractionEnabled = false
        
        self.joinVM.joinEvent(ByEventid: self.eventId,JoinDate:JoinDate ,Jointime:Jointime) { error, data in
            
            
            if let error = error {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("handleEventDetails"), object: nil, userInfo: nil)
            }
        }
    }
    
    func statusEvent(_ model: Event?, _ cell: EventButtonsTableViewCell) {
        if model?.key == 1 { //my event
            cell.editBtn.isHidden = false
            cell.chatBtn.isHidden = false
            cell.joinBtn.isHidden = true
            cell.leaveBtn.isHidden = true
            self.isEventAdmin = true
        }
        else if model?.key == 2 { // not join
            cell.editBtn.isHidden = true
            cell.chatBtn.isHidden = true
            cell.joinBtn.isHidden = false
            cell.leaveBtn.isHidden = true
            self.isEventAdmin = false
        }
        else { // join
            cell.editBtn.isHidden = true
            cell.chatBtn.isHidden = false
            cell.joinBtn.isHidden = true
            cell.leaveBtn.isHidden = false
            self.isEventAdmin = false
        }
    }
    func handleEventChat(_ model:Event?,_ JoinDate:String,_ Jointime:String) {
        if model?.leveevent == 1 {
            guard let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC else {return}
            vc.isEvent = true
            vc.eventChatID = self.eventId
            vc.chatuserID = ""
            vc.leavevent = 0
            vc.leaveGroup = 1
            vc.isFriend = false
            vc.titleChatImage = model?.image ?? ""
            vc.titleChatName = model?.title ?? ""
            vc.isChatGroupAdmin = false
            vc.isChatGroup = false
            vc.groupId = ""
            vc.isEventAdmin = self.isEventAdmin
            CancelRequest.currentTask = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            joinEventChat(JoinDate, Jointime, model)
        }
    }
    func joinEventChat(_ JoinDate: String, _ Jointime: String, _ model: Event?) {
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
                guard let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC else {return}
                vc.isEvent = true
                vc.eventChatID = self.eventId
                vc.chatuserID = ""
                vc.leavevent = 0
                vc.leaveGroup = 1
                vc.isFriend = false
                vc.titleChatImage = model?.image ?? ""
                vc.titleChatName = model?.title ?? ""
                vc.isChatGroupAdmin = false
                vc.isChatGroup = false
                vc.groupId = ""
                vc.isEventAdmin = self.isEventAdmin
                CancelRequest.currentTask = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    func leaveEvent(_ cell:EventButtonsTableViewCell,_ JoinDate:String,_ Jointime:String) {
        self.changeTitleBtns(btn: cell.leaveBtn, title: "Leaving...".localizedString)
        cell.leaveBtn.isUserInteractionEnabled = false
        leaveRequest(JoinDate, Jointime)
    }
    func leaveRequest(_ JoinDate: String, _ Jointime: String) {
        self.leaveVM.leaveEvent(ByEventid: self.eventId,leaveeventDate: JoinDate,leaveeventtime: Jointime) { error, data in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = data else {return}
            
            DispatchQueue.main.async {
                if self.selectedVC {
                    Router().toInbox()
                }else {
                    self.onPopup()
                }
            }
        }
    }
    func statisticsEvent(_ cell: StatisticsDetailsTableViewCell, _ model: Event?) {
        cell.femaleLbl.text = "Female"
        cell.maleLbl.text = "Male"
        cell.otherLbl.text = "Other Gender"
        
        cell.interest1Lbl.text = model?.interestStatistic?[0].name
        cell.interest2Lbl.text = model?.interestStatistic?[1].name
        cell.interest3Lbl.text = model?.interestStatistic?[2].name
        
        cell.interest1PercentageLbl.text = "\(model?.interestStatistic?[0].interestcount ?? 0) %"
        cell.interest2PercentageLbl.text = "\(model?.interestStatistic?[1].interestcount ?? 0) %"
        cell.interest3PercentageLbl.text = "\(model?.interestStatistic?[2].interestcount ?? 0) %"
        
        cell.interest1Slider.value = Float(model?.interestStatistic?[0].interestcount ?? 0)
        cell.interest2Slider.value = Float(model?.interestStatistic?[1].interestcount ?? 0)
        cell.interest3Slider.value = Float(model?.interestStatistic?[2].interestcount ?? 0)
        
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                if (model?.interestStatistic?[0].interestcount ?? 0) == 0 {
                    cell.interest1Slider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    cell.interest1Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if (model?.interestStatistic?[0].interestcount ?? 0) == 100 {
                    cell.interest1Slider.maximumTrackTintColor = .blue
                    cell.interest1Slider.minimumTrackTintColor = .blue
                }else {
                    cell.interest1Slider.minimumTrackTintColor = .blue
                    cell.interest1Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }
            }
            DispatchQueue.main.async {
                if (model?.interestStatistic?[1].interestcount ?? 0) == 0 {
                    cell.interest2Slider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    cell.interest2Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if (model?.interestStatistic?[1].interestcount ?? 0) == 100 {
                    cell.interest2Slider.maximumTrackTintColor = .red
                    cell.interest2Slider.minimumTrackTintColor = .red
                    
                }else {
                    cell.interest2Slider.minimumTrackTintColor = .red
                    cell.interest2Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }
            }
            DispatchQueue.main.async {
                if (model?.interestStatistic?[2].interestcount ?? 0) == 0 {
                    cell.interest3Slider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    cell.interest3Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }
                else if (model?.interestStatistic?[2].interestcount ?? 0) == 100 {
                    cell.interest3Slider.maximumTrackTintColor = .green
                    cell.interest3Slider.minimumTrackTintColor = .green
                    
                }
                else {
                    cell.interest3Slider.minimumTrackTintColor = .green
                    cell.interest3Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    
                }
            }
        }
        
        for itm in model?.genderStatistic ?? [] {
            if itm.key == "Male" {
                cell.maleSlider.value = Float(itm.gendercount ?? 0)
                
                if itm.gendercount == 0 {
                    cell.maleSlider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    cell.maleSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if itm.gendercount == 100 {
                    cell.maleSlider.minimumTrackTintColor = .blue
                    cell.maleSlider.maximumTrackTintColor = .blue
                }else {
                    cell.maleSlider.minimumTrackTintColor = .blue
                    cell.maleSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }
                
                cell.malePercentageLbl.text = "\(itm.gendercount ?? 0) %"
            }
            else if itm.key == "Female" {
                cell.femaleSlider.value = Float(itm.gendercount ?? 0)
                
                if itm.gendercount == 0 {
                    cell.femaleSlider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    cell.femaleSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if itm.gendercount == 100 {
                    cell.femaleSlider.minimumTrackTintColor = .red
                    cell.femaleSlider.maximumTrackTintColor = .red
                    
                }else {
                    cell.femaleSlider.minimumTrackTintColor = .red
                    cell.femaleSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }
                
                cell.femalePercentageLbl.text = "\(itm.gendercount ?? 0) %"
            }
            else {
                cell.otherSlider.value = Float(itm.gendercount ?? 0)
                
                if itm.gendercount == 0 {
                    cell.otherSlider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    cell.otherSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }else if itm.gendercount == 100 {
                    cell.otherSlider.minimumTrackTintColor = .green
                    cell.otherSlider.maximumTrackTintColor = .green
                    
                }else {
                    cell.otherSlider.minimumTrackTintColor = .green
                    cell.otherSlider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                }
                
                cell.otherPercentageLbl.text = "\(itm.gendercount ?? 0) %"
            }
        }
    }
    func directionEventInMap(_ model:Event?,_ lat:Double,_ lng:Double) {
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(model?.lat ?? ""),\(model?.lang ?? "")&directionsmode=driving")!)
        }
        else {
            let coordinates = CLLocationCoordinate2DMake(lat,lng)
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
