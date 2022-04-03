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
import GoogleMobileAds
import MapKit
import Network

class DynamicLabel: UILabel {
    
    var fullText: String?
    var truncatedLength = 100
    var isTruncated = true
    
    func collapse(){
        let index = fullText!.index(fullText!.startIndex, offsetBy: truncatedLength)
        self.text = fullText![...index].description + "... More"
        isTruncated = true
    }
    
    func expand(){
        self.text = fullText
        isTruncated = false
    }
}

class ExternalEventDetailsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var imagesView: [UIImageView]!
    
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
    
    var locationTitle = ""
    var internetConect:Bool = false
    
    var visibleIndexPath:Int = 0
    var encryptedID:String = ""
    lazy var refreshControl: UIRefreshControl = UIRefreshControl()
    var isConv:Bool = false

    var myString:String = ""
    var myMutableString = NSMutableAttributedString()

    var isEventAdmin: Bool = false
    var selectedVC:Bool = false
    var isprivateEvent:Bool = false
    
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
        if selectedVC {
            Defaults.availableVC = "PresentEventDetailsViewController"
        }else {
            Defaults.availableVC = "EventDetailsViewController"
        }
        print("availableVC >> \(Defaults.availableVC)")
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        setupNavBar()
        hideNavigationBar(NavigationBar: false, BackButton: false)
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
    
    //MARK:- APIs
    
    func updateUserInterface() {
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.internetConect = true
                    self.loadEventDataDetails()
                }
            }else {
                DispatchQueue.main.async {
                    self.internetConect = false
                    self.HandleInternetConnection()
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)

    }
    
    @objc func handleExternalEventDetails() {
        self.getEventDetails()
    }
    
    func getEventDetails() {
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now()) {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    if value.key == 1 {
                        self.isEventAdmin = true
                    }else {
                        self.isEventAdmin = false
                    }
                    
                    self.initOptionsEventButton()
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
    
    func loadEventDataDetails() {
        self.hideView.isHidden = false
        self.hideView.showLoader()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            
            DispatchQueue.main.async {
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    self.hideView.hideLoader()
                    self.hideView.isHidden = true
                }
                
                DispatchQueue.main.async {
                    if value.key == 1 {
                        self.isEventAdmin = true
                    }else {
                        self.isEventAdmin = false
                    }
                    
                    self.initOptionsEventButton()
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
}

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
            cell.eventImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "placeHolderApp"))
            cell.titleLbl.text = model?.title
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
            
            cell.HandleChatBtn = {
                if model?.leveevent == 1 {
                    let vc = ConversationVC()
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
                            let vc = ConversationVC()
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
            }
            
            cell.HandleLeaveBtn = {
                if self.internetConect == true {
                    self.changeTitleBtns(btn: cell.leaveBtn, title: "Leaving...".localizedString)
                    cell.leaveBtn.isUserInteractionEnabled = false

                    self.leaveVM.leaveEvent(ByEventid: self.eventId,leaveeventDate: JoinDate,leaveeventtime: Jointime) { error, data in
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = data else {return}
                        
//                        DispatchQueue.main.async {
//                            cell.leaveBtn.isHidden = true
//                            cell.leaveBtn.setTitle("Leave", for: .normal)
//                            cell.joinBtn.isHidden = false
//                            cell.leaveBtn.isUserInteractionEnabled = true
//                        }
                        
                        DispatchQueue.main.async {
                            if self.selectedVC {
                                Router().toHome()
                            }else {
                                self.onPopup()
                            }
                            //                            if model?.eventtype == "Private" {
                            //                                if self.selectedVC {
                            //                                    Router().toHome()
                            //                                }else {
                            //                                    self.onPopup()
                            //                                }
                            //                            }
                            //                            else {
                            //                                self.onPopup()
                            //                            }
                        }
                    }
                }else {
                    return
                }
            }
            
            cell.HandleJoinBtn = {
                let JoinDate = self.formatterDate.string(from: Date())
                let Jointime = self.formatterTime.string(from: Date())
                
                if self.internetConect == true {
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
                            cell.joinBtn.isHidden = true
                            cell.joinBtn.setTitle("Join", for: .normal)
                            cell.joinBtn.isUserInteractionEnabled = true
                            cell.leaveBtn.isHidden = false
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("handleExternalEventDetails"), object: nil, userInfo: nil)
                            }
                        }
                    }
                }else {
                    return
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
            
            DispatchQueue.main.async {
                cell.detailsLbl.addTrailing(with: "... ", moreText: "Read more", moreTextFont: UIFont(name: "Montserrat-Medium", size: 12)!, moreTextColor: UIColor.FriendzrColors.primary!)
            }
            
            return cell
        }
        
        else if indexPath.row == 4 {//ads
            guard let cell = tableView.dequeueReusableCell(withIdentifier: adsCellId, for: indexPath) as? AdsTableViewCell else {return UITableViewCell()}
            cell.parentVC = self
            return cell
        }
        
        else if indexPath.row == 5 {//statistics
            guard let cell = tableView.dequeueReusableCell(withIdentifier: statisticsCellId, for: indexPath) as? StatisticsDetailsTableViewCell else {return UITableViewCell()}
            
            cell.titleView.isHidden = false
            cell.titleViewHeight.constant = 35
            cell.bottomTitleViewLayoutConstraint.constant = 0
            cell.titleView.setCornerforTop()
            cell.containerView.setCornerforBottom()
            
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
                    }else if (model?.interestStatistic?[0].interestcount ?? 0) == 100 {
                        cell.interest1Slider.maximumTrackTintColor = .blue
                    }else {
                        cell.interest1Slider.minimumTrackTintColor = .blue
                        cell.interest1Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }
                }
                
                DispatchQueue.main.async {
                    if (model?.interestStatistic?[1].interestcount ?? 0) == 0 {
                        cell.interest2Slider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }else if (model?.interestStatistic?[1].interestcount ?? 0) == 100 {
                        cell.interest2Slider.maximumTrackTintColor = .red
                    }else {
                        cell.interest2Slider.minimumTrackTintColor = .red
                        cell.interest2Slider.maximumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }
                }
                DispatchQueue.main.async {
                    if (model?.interestStatistic?[2].interestcount ?? 0) == 0 {
                        cell.interest3Slider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }
                    else if (model?.interestStatistic?[2].interestcount ?? 0) == 100 {
                        cell.interest3Slider.maximumTrackTintColor = .green
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
                    
                    cell.maleSlider.minimumTrackTintColor = .blue
                    if itm.gendercount == 0 {
                        cell.maleSlider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }else if itm.gendercount == 100 {
                        cell.maleSlider.maximumTrackTintColor = .blue
                    }
                    
                    cell.malePercentageLbl.text = "\(itm.gendercount ?? 0) %"
                }
                else if itm.key == "Female" {
                    cell.femaleSlider.value = Float(itm.gendercount ?? 0)
                    
                    cell.femaleSlider.minimumTrackTintColor = .red
                    if itm.gendercount == 0 {
                        cell.femaleSlider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }else if itm.gendercount == 100 {
                        cell.femaleSlider.maximumTrackTintColor = .red
                    }
                    
                    cell.femalePercentageLbl.text = "\(itm.gendercount ?? 0) %"
                }else {
                    cell.otherSlider.value = Float(itm.gendercount ?? 0)
                    
                    cell.otherSlider.minimumTrackTintColor = .green
                    if itm.gendercount == 0 {
                        cell.otherSlider.minimumTrackTintColor = .lightGray.withAlphaComponent(0.3)
                    }else if itm.gendercount == 100 {
                        cell.otherSlider.maximumTrackTintColor = .green
                    }
                    
                    cell.otherPercentageLbl.text = "\(itm.gendercount ?? 0) %"
                }
            }
            
            return cell
        }
        
        else {//map
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
    }
}

extension ExternalEventDetailsVC: UITableViewDelegate,UIPopoverPresentationControllerDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return screenH/3
        }else if indexPath.row == 1 {
            return 70
        }else if indexPath.row == 2 {
            return 100
        }else if indexPath.row == 3 {
            return 150
        }else if indexPath.row == 4 {//ads
            return UITableView.automaticDimension
        }else if indexPath.row == 5 {
            return 290
        }else {
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewmodel.event.value
        
        if indexPath.row == 3 {
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

extension ExternalEventDetailsVC:GADBannerViewDelegate {
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

extension ExternalEventDetailsVC {
    
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if self.viewmodel.event.value?.eventtype == "Private" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SharePrivateEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? SharePrivateEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.id = self.eventId
                    vc.isEvent = true
                    vc.selectedVC = "PresentC"
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
                if self.viewmodel.event.value?.eventtype == "Private" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SharePrivateEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? SharePrivateEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
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
    }
    
    @objc func handleEventReportBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Report".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Main, AndContollerID: "ReportNC") as? UINavigationController, let vc = controller.viewControllers.first as? ReportVC {
                    vc.id = self.eventId
                    vc.isEvent = true
                    vc.selectedVC = "PresentC"
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
    }
    @objc func handleShareOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if self.viewmodel.event.value?.eventtype == "Private" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SharePrivateEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? SharePrivateEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
                }
            }))
            actionAlert.addAction(UIAlertAction(title: "Cancel".localizedString, style: .cancel, handler: {  _ in
            }))
            
            present(actionAlert, animated: true, completion: nil)
        }
        else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if self.viewmodel.event.value?.eventtype == "Private" {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "SharePrivateEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? SharePrivateEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
                }else {
                    if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareEventNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareEventVC {
                        vc.eventID = self.viewmodel.event.value?.id ?? ""
                        self.present(controller, animated: true)
                    }
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