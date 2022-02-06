//
//  EventDetailsVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 17/08/2021.
//

import UIKit
import SwiftUI
import SDWebImage
import GoogleMaps
import Alamofire
import ListPlaceholder
import GoogleMobileAds
import MapKit

class EventDetailsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var dateCreateLbl: UILabel!
    @IBOutlet weak var timeCreateLbl: UILabel!
    @IBOutlet weak var attendLbl: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var descreptionLbl: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var interestsStatisticsView: UIView!
    @IBOutlet weak var attendeesTableView: UITableView!
    @IBOutlet weak var attendeesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var eventTitleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateAndTimeView: UIView!
    @IBOutlet weak var attendeesView: UIView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet var bannerView: GADBannerView!
    
    
    
    lazy var alertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    
    //MARK: - Properties
    var numbers:[Double] = [1,2,3]
    var genders:[String] = ["Men","Women","Other Gender"]
    let attendeesCellID = "AttendeesTableViewCell"
    private var footerCellID = "SeeMoreTableViewCell"
    let statisticsCellID = "StatisticsCollectionViewCell"
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
    var refreshControl = UIRefreshControl()
    
    
    private let formatterDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.dateFormat = "yyyy-MM-dd"
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
        
        
        setupViews()
        pullToRefresh()
        
        //        initBackColorButton()
        //        initOptionsEventButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearNavigationBar()
        
        DispatchQueue.main.async {
            self.updateUserInterface()
        }
        
        hideNavigationBar(NavigationBar: false, BackButton: true)
        
        CancelRequest.currentTask = false
        seyupAds()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    func seyupAds() {
        bannerView.adUnitID = adUnitID
        //        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.cornerRadiusView(radius: 12)
    }
    
    //MARK: - Helper
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        updateUserInterface()
        self.refreshControl.endRefreshing()
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
    
    func HandleInternetConnection() {
        self.view.makeToast("No avaliable network ,Please try again!".localizedString)
    }
    
    func setupViews() {
        editBtn.cornerRadiusView(radius: 8)
        joinBtn.cornerRadiusView(radius: 8)
        leaveBtn.cornerRadiusView(radius: 8)
        detailsView.cornerRadiusView(radius: 21)
        interestsStatisticsView.cornerRadiusView(radius: 21)
        backBtn.cornerRadiusForHeight()
        menuBtn.cornerRadiusForHeight()
        
        attendeesTableView.register(UINib(nibName: attendeesCellID, bundle: nil), forCellReuseIdentifier: attendeesCellID)
        attendeesTableView.register(UINib(nibName: footerCellID, bundle: nil), forHeaderFooterViewReuseIdentifier: footerCellID)
        collectionView.register(UINib(nibName: statisticsCellID, bundle: nil), forCellWithReuseIdentifier: statisticsCellID)
        
        //        collectionView.register(UINib(nibName: interestCellID, bundle: nil), forCellWithReuseIdentifier: interestCellID)
        //        collectionView.register(UINib(nibName: genderCellID, bundle: nil), forCellWithReuseIdentifier: genderCellID)
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
    
    func setupData() {
        let model = viewmodel.event.value
        eventTitleLbl.text = model?.title
        dateCreateLbl.text = model?.datetext
        
        if model?.timefrom != "" && model?.allday == false {
            timeCreateLbl.text = model?.timetext
        }else {
            timeCreateLbl.text = "All Day".localizedString
        }
        
        attendLbl.text = "Attendees : ".localizedString + "\(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
        categoryNameLbl.text = model?.categorie
        descreptionLbl.text = model?.descriptionEvent
        encryptedID = model?.encryptedID ?? ""
        eventImg.sd_setImage(with: URL(string: model?.image ?? ""), placeholderImage: UIImage(named: "placeholder"))
        if model?.key == 1 { //my event
            editBtn.isHidden = false
            chatBtn.isHidden = false
            joinBtn.isHidden = true
            leaveBtn.isHidden = true
        }else if model?.key == 2 { // not join
            editBtn.isHidden = true
            chatBtn.isHidden = true
            joinBtn.isHidden = false
            leaveBtn.isHidden = true
            attendeesViewHeight.constant = 0
        }else { // join
            editBtn.isHidden = true
            chatBtn.isHidden = false
            joinBtn.isHidden = true
            leaveBtn.isHidden = false
            attendeesViewHeight.constant = 0
            
        }
        
        attendeesView.cornerRadiusView(radius: 21)
        dateAndTimeView.cornerRadiusView(radius: 12)
        mapContainerView.cornerRadiusView(radius: 16)
        mapView.cornerRadiusView(radius: 16)
        
        
        setupGoogleMap(location: CLLocationCoordinate2D(latitude: Double((model?.lat)!)!, longitude: Double((model?.lang!)!)!))
    }
    
    func setupMarker(for position:CLLocationCoordinate2D)  {
        self.mapView.clear()
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(systemName: "default_marker.png")
        marker.title = locationTitle
        marker.map = mapView
    }
    
    
    func setupGoogleMap(location:CLLocationCoordinate2D) {
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.isBuildingsEnabled = true
        self.mapView.isIndoorEnabled = true
        self.mapView.isUserInteractionEnabled = false
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 16.0)
        self.mapView.animate(to: camera)
        
        geocode(latitude: location.latitude, longitude: location.longitude) { (PM, error) in
            
            guard let error = error else {
                self.locationTitle = PM?.name ?? ""
                self.setupMarker(for: location)
                return
            }
            
            self.showAlert(withMessage: error.localizedDescription)
        }
    }
    
    private func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemark, error in
            guard let fplacemark = placemark?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(fplacemark, nil)
        }
    }
    
    //MARK:- APIs
    func getEventDetails() {
        self.superView.hideLoader()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.reloadData()
                
                attendeesTableView.delegate = self
                attendeesTableView.dataSource = self
                attendeesTableView.reloadData()
                
                setupData()
                
                if value.attendees?.count == 0 {
                    attendeesViewHeight.constant = 0
                }else if value.attendees?.count == 1 {
                    attendeesViewHeight.constant = CGFloat(120)
                }else if value.attendees?.count == 2 {
                    attendeesViewHeight.constant = CGFloat(220)
                }else {
                    attendeesViewHeight.constant = CGFloat(275)
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
        self.superView.showLoader()
        viewmodel.getEventByID(id: eventId)
        viewmodel.event.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.reloadData()
                
                attendeesTableView.delegate = self
                attendeesTableView.dataSource = self
                attendeesTableView.reloadData()
                
                setupData()
                
                if value.attendees?.count == 0 {
                    attendeesViewHeight.constant = 0
                }else if value.attendees?.count == 1 {
                    attendeesViewHeight.constant = CGFloat(120)
                }else if value.attendees?.count == 2 {
                    attendeesViewHeight.constant = CGFloat(220)
                }else {
                    attendeesViewHeight.constant = CGFloat(275)
                }
                
                self.superView.hideLoader()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func editBtn(_ sender: Any) {
        showNewtworkConnected()
        if internetConect == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EditEventsVC") as? EditEventsVC else {return}
            vc.eventModel = viewmodel.event.value
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            return
        }
    }
    
    @IBAction func joinBtn(_ sender: Any) {
        showNewtworkConnected()
        
        let JoinDate = self.formatterDate.string(from: Date())
        let Jointime = self.formatterTime.string(from: Date())
        
        if internetConect == true {
            joinBtn.isUserInteractionEnabled = false
            joinVM.joinEvent(ByEventid: viewmodel.event.value?.id ?? "",JoinDate:JoinDate ,Jointime:Jointime) { error, data in
                self.joinBtn.isUserInteractionEnabled = true
                if let error = error {
                    self.hideLoading()
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                DispatchQueue.main.async {
                    self.joinBtn.isUserInteractionEnabled = true
                    self.view.makeToast("You have successfully subscribed to event".localizedString)
                }
                
                self.getEventDetails()
            }
        }else {
            return
        }
    }
    
    @IBAction func leaveBtn(_ sender: Any) {
        showNewtworkConnected()
        if internetConect == true {
            leaveBtn.isUserInteractionEnabled = false
            leaveVM.leaveEvent(ByEventid: viewmodel.event.value?.id ?? "") { error, data in
                self.leaveBtn.isUserInteractionEnabled = true
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    self.leaveBtn.isUserInteractionEnabled = true
                    self.view.makeToast("You have successfully leave event".localizedString)
                }
                
                self.getEventDetails()
            }
        }else {
            return
        }
    }
    
    @IBAction func chatBtn(_ sender: Any) {
        let JoinDate = self.formatterDate.string(from: Date())
        let Jointime = self.formatterTime.string(from: Date())
        
        if viewmodel.event.value?.leveevent == 1 {
            Router().toConversationVC(isEvent: true, eventChatID: eventId, leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: viewmodel.event.value?.image ?? "", titleChatName: viewmodel.event.value?.title ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1)
        }else {
            self.view.makeToast("Wait, I'll join you in the event chat...".localizedString)
            joinCahtEventVM.joinChat(ByID: eventId, ActionDate: JoinDate, Actiontime: Jointime) { error, data in
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    self.view.makeToast("You have now joined the chat event".localizedString)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Router().toConversationVC(isEvent: true, eventChatID: self.eventId, leavevent: 0, chatuserID: "", isFriend: false, titleChatImage: self.viewmodel.event.value?.image ?? "", titleChatName: self.viewmodel.event.value?.title ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1)
                }
                
            }
            
        }
    }
    
    @IBAction func openGoogleDirectionsMapBtn(_ sender: Any) {
        let model = viewmodel.event.value
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!) {
            UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(model?.lat ?? ""),\(model?.lang ?? "")&directionsmode=driving")!)
        }else {
            let lat = Double("\(model?.lat ?? "")")
            let lng = Double("\(model?.lang ?? "")")
            
            let source = MKMapItem(coordinate: .init(latitude: lat ?? 0.0, longitude: lng ?? 0.0), name: "Source")
            let destination = MKMapItem(coordinate: .init(latitude: lat ?? 0.0, longitude: lng ?? 0.0), name: model?.title ?? "")
            
            MKMapItem.openMaps(
                with: [source, destination],
                launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            )
        }
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.onPopup()
    }
    
    @IBAction func menuBtn(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareVC {
                    vc.encryptedID = self.encryptedID
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
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                if let controller = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ShareNC") as? UINavigationController, let vc = controller.viewControllers.first as? ShareVC {
                    vc.encryptedID = self.encryptedID
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
    
}

extension EventDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.event.value?.attendees?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: attendeesCellID, for: indexPath) as? AttendeesTableViewCell else {return UITableViewCell()}
        let model = viewmodel.event.value?.attendees?[indexPath.row]
        
        cell.joinDateLbl.isHidden = true
        cell.friendNameLbl.text = model?.userName
        cell.friendImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
        
        if indexPath.row == (viewmodel.event.value?.attendees?.count ?? 0) - 1 {
            cell.underView.isHidden = true
        }else {
            cell.underView.isHidden = false
        }
        
        if model?.myEventO == true {
            cell.adminLbl.isHidden = false
            cell.dropDownBtn.isHidden = true
            cell.btnWidth.constant = 0
        }else {
            cell.adminLbl.isHidden = true
            cell.dropDownBtn.isHidden = false
            cell.btnWidth.constant = 20
        }
        
        cell.HandleDropDownBtn = {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle: .alert)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Delete".localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "delete", eventID: self.viewmodel.event.value?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 1)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Block".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "block".localizedString, eventID: self.viewmodel.event.value?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 2)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString.localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
            }else {
                let settingsActionSheet: UIAlertController = UIAlertController(title:nil, message:nil, preferredStyle:UIAlertController.Style.actionSheet)
                
                settingsActionSheet.addAction(UIAlertAction(title:"Delete".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "delete".localizedString, eventID: self.viewmodel.event.value?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 1)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Block".localizedString.localizedString, style:UIAlertAction.Style.default, handler:{ action in
                    self.showAlertView(messageString: "block".localizedString, eventID: self.viewmodel.event.value?.id ?? "", UserattendId: model?.userId ?? "", Stutus: 2)
                }))
                settingsActionSheet.addAction(UIAlertAction(title:"Cancel".localizedString, style:UIAlertAction.Style.cancel, handler:nil))
                
                self.present(settingsActionSheet, animated:true, completion:nil)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        guard let footerView = Bundle.main.loadNibNamed(footerCellID, owner: self, options: nil)?.first as? SeeMoreTableViewCell else { return UIView()}
        
        footerView.HandleSeeMoreBtn = {
            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AttendeesVC") as? AttendeesVC else {return}
            vc.eventID = self.viewmodel.event.value?.id ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (viewmodel.event.value?.attendees?.count ?? 0) > 1 {
            return 40
        }else {
            return 0
        }
    }
}

extension EventDetailsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewmodel.event.value?.attendees?[indexPath.row]
        
        if model?.myEventO == true {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileVC") as? MyProfileVC else {return}
            self.navigationController?.pushViewController(vc, animated: true)
        }else {
            guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
            vc.userID = model?.userId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EventDetailsVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        if indexPath.row == 0 {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statisticsCellID, for: indexPath) as? StatisticsCollectionViewCell else {return UICollectionViewCell()}
        cell.genderModel = viewmodel.event.value?.genderStatistic
        cell.interestModel = viewmodel.event.value?.interestStatistic
        cell.parentVC = self
        cell.genderTV.reloadData()
        cell.interestTV.reloadData()
        return cell
        //        }else {
        //            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: interestCellID, for: indexPath) as? InterestsCollectionViewCell else {return UICollectionViewCell()}
        //            cell.model = viewmodel.event.value?.interestStatistic
        //            cell.parentVC = self
        //            cell.tableView.reloadData()
        //            return cell
        //        }
    }
}

extension EventDetailsVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width - 32
        let height = collectionView.frame.height - 16
        
        return CGSize(width: width, height: height)
    }
    
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //
    //        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
    //        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    //        let visibleIndexPatho = collectionView.indexPathForItem(at: visiblePoint)
    //        print("visibleIndexPatho : \(visibleIndexPatho?.row ?? 0)")
    //
    //        //        for cell in collectionView.visibleCells {
    //        //            let indexPath = collectionView.indexPath(for: cell)
    //        //            print("indexPath : \(indexPath?.row ?? 0)")
    //        //
    //        visibleIndexPath = visibleIndexPatho?.row ?? 0
    //        //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

extension EventDetailsVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard let rootViewController = Initializer.getWindow().rootViewController else {
            return
        }
        let tabBarController = rootViewController as? UITabBarController
        tabBarController?.selectedIndex = 1
    }
}

extension EventDetailsVC:GADBannerViewDelegate {
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

extension EventDetailsVC {
    func initOptionsEventButton() {
        let imageName = "menu_WH_ic"
        let button = UIButton.init(type: .custom)
        let image = UIImage.init(named: imageName)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.backgroundColor = UIColor.FriendzrColors.primary?.withAlphaComponent(0.5)
        button.cornerRadiusForHeight()
        button.setImage(image, for: .normal)
        image?.withTintColor(UIColor.blue)
        button.addTarget(self, action:  #selector(handleEventOptionsBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleEventOptionsBtn() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let actionAlert  = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            actionAlert.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                //                self.shareEvent()
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
        }else {
            let actionSheet  = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Share".localizedString, style: .default, handler: { action in
                //                self.shareEvent()
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
    
    
    
    func showAlertView(messageString:String,eventID:String,UserattendId:String,Stutus :Int) {
        self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        self.alertView?.titleLbl.text = "Confirm?".localizedString
        self.alertView?.detailsLbl.text = "Are you sure you want to ".localizedString + "\(messageString)" + " this account?".localizedString
        
        let ActionDate = self.formatterDate.string(from: Date())
        let Actiontime = self.formatterTime.string(from: Date())
        
        self.alertView?.HandleConfirmBtn = {
            // handling code
            self.attendeesVM.editAttendees(ByUserAttendId: UserattendId, AndEventid: eventID, AndStutus: Stutus,Actiontime: Actiontime ,ActionDate: ActionDate) { [self] error, data in
                self.hideLoading()
                if let error = error {
                    DispatchQueue.main.async {
                        self.view.makeToast(error)
                    }
                    
                    return
                }
                
                guard let _ = data else {return}
                
                DispatchQueue.main.async {
                    self.view.makeToast("Successfully" )
                }
                
                DispatchQueue.main.async {
                    self.getEventDetails()
                }
            }
            
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
