//
//  FeedVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import SwiftUI
import CoreLocation
import Contacts
import ListPlaceholder
import GoogleMobileAds
import SDWebImage
import Network
import AppTrackingTransparency
import AdSupport
import AMShimmer
import FirebaseAnalytics

let screenH: CGFloat = UIScreen.main.bounds.height
let screenW: CGFloat = UIScreen.main.bounds.width

extension FeedVC {
    
    func checkLocationPermission() {
        
        self.refreshControl.endRefreshing()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                //                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                Defaults.allowMyLocationSettings = false
                hideView.isHidden = true
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                switchCompassBarButton.isUserInteractionEnabled = false
                switchGhostModeBarButton.isUserInteractionEnabled = false
                self.switchSortedByInterestsButton.isUserInteractionEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                hideView.isHidden = true
                
                if !Defaults.isFirstOpenFeed {
                    showCompassExplainedView.isHidden = false
                    showPrivateModeExplainedView.isHidden = true
                    showSortByInterestsExplainedView.isHidden = true
                    
                    switchSortedByInterestsButton.isUserInteractionEnabled = false
                    switchCompassBarButton.isUserInteractionEnabled = false
                    switchGhostModeBarButton.isUserInteractionEnabled = false
                }else {
                    showCompassExplainedView.isHidden = true
                    showPrivateModeExplainedView.isHidden = true
                    showSortByInterestsExplainedView.isHidden = true
                    
                    switchSortedByInterestsButton.isUserInteractionEnabled = true
                    switchCompassBarButton.isUserInteractionEnabled = true
                    switchGhostModeBarButton.isUserInteractionEnabled = true
                }
                
                setupCompassContainerView()
                
                DispatchQueue.main.async {
                    self.updateUserInterface()
                }
                
                switchCompassBarButton.isUserInteractionEnabled = true
                switchGhostModeBarButton.isUserInteractionEnabled = true
                switchSortedByInterestsButton.isUserInteractionEnabled = true
//                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            hideView.isHidden = true
            switchCompassBarButton.isUserInteractionEnabled = false
            switchGhostModeBarButton.isUserInteractionEnabled = false
            switchSortedByInterestsButton.isUserInteractionEnabled = false
            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            //            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
    
    //create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localizedString, style: .cancel)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString, comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func checkLocationPermissionBtns() {
        self.refreshControl.endRefreshing()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                Defaults.allowMyLocationSettings = false
                hideView.isHidden = true
                switchCompassBarButton.isUserInteractionEnabled = false
                switchGhostModeBarButton.isUserInteractionEnabled = false
                switchSortedByInterestsButton.isUserInteractionEnabled = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                hideView.isHidden = true
                switchCompassBarButton.isUserInteractionEnabled = true
                switchGhostModeBarButton.isUserInteractionEnabled = true
                switchSortedByInterestsButton.isUserInteractionEnabled = true
                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            hideView.isHidden = true
            switchCompassBarButton.isUserInteractionEnabled = false
            switchGhostModeBarButton.isUserInteractionEnabled = false
            switchSortedByInterestsButton.isUserInteractionEnabled = false
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
}

class FeedVC: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var compassContanierView: UIView!
    @IBOutlet weak var compassContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var allowLocView: UIView!
    @IBOutlet weak var next1Btn: UIButton!
    @IBOutlet weak var next2Btn: UIButton!
    @IBOutlet weak var next3Btn: UIButton!
    @IBOutlet weak var showCompassExplainedView: UIView!
    @IBOutlet weak var showPrivateModeExplainedView: UIView!
    @IBOutlet weak var showSortByInterestsExplainedView: UIView!
    @IBOutlet weak var dialogimg: UIImageView!
    @IBOutlet weak var allowBtn: UIButton!
    @IBOutlet var bannerView: UIView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hidesImgs: [UIImageView]!
    @IBOutlet var proImgs: [UIImageView]!
    @IBOutlet weak var sortDialogueLbl: UILabel!
    @IBOutlet weak var privateModelDialogueLbl: UILabel!
    @IBOutlet weak var compasslDialogueLbl: UILabel!
    
    var bannerView2: GADBannerView!
    
    //MARK: - Properties
    private lazy var currLocation: CLLocation = CLLocation()
    private lazy var locationManager : CLLocationManager = CLLocationManager()
    
    /// Scale view
    private lazy var dScaView: DegreeScaleView = {
        let viewF = CGRect(x: 0, y: 0, width: screenW, height: screenW)
        let scaleV = DegreeScaleView(frame: viewF)
        scaleV.backgroundColor = UIColor.FriendzrColors.primary
        return scaleV
    }()
    
    lazy var showAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
    lazy var alertView = Bundle.main.loadNibNamed("HideGhostModeView", owner: self, options: nil)?.first as? HideGhostModeView
    
    lazy var showSortView = Bundle.main.loadNibNamed("SortFeedView", owner: self, options: nil)?.first as? SortFeedView
    
    private func createLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 0
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.headingAvailable() {
            locationManager.startUpdatingLocation()     //Start location service
            locationManager.startUpdatingHeading()      //Start getting device orientation
            print("Start Positioning")
        }
        else {
            print("Cannot get heading data")
        }
    }
    
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
    
    var compassDegree:Double = 0.0
    var filterDir = false
    
    let cellID = "UsersFeedTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:FeedViewModel = FeedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    var settingVM:SettingsViewModel = SettingsViewModel()
    
    var refreshControl = UIRefreshControl()
    let switchCompassBarButton: CustomSwitch = CustomSwitch()
    var switchGhostModeBarButton: CustomSwitch = CustomSwitch()
    var switchSortedByInterestsButton: CustomSwitch = CustomSwitch()
    
    var titleViewBtn:UIButton = UIButton()
    var btnsSelected:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    var isSendRequest:Bool = false
    
    var locationLat = 0.0
    var locationLng = 0.0
    
    var isCompassOpen:Bool = false
    var sortByInterestMatch:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed".localizedString
        pullToRefresh()
        addCompassView()
        
        setupNavBar()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeeds), name: Notification.Name("updateFeeds"), object: nil)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        initCompassSwitchBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPage = 1
        setup()
        Defaults.availableVC = "FeedVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        CancelRequest.currentTask = false
        setupHideView()
        
        if Defaults.isSubscribe == false {
            requestIDFA()
            bannerViewHeight.constant = 50
        }else {
            bannerViewHeight.constant = 0
        }
        
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.checkLocationPermission()
            }
        }
        
        initGhostModeAndSortSwitchButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    
    //MARK: - APIs
    func updateUserInterface() {
        appDelegate.networkReachability()
        
//        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
//          AnalyticsParameterItemID: "id-\(title!)",
//          AnalyticsParameterItemName: title!,
//          AnalyticsParameterContentType: "cont",
//        ])

        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                self.emptyView.isHidden = false
                self.hideView.isHidden = true
                if Defaults.allowMyLocationSettings == true {
                    self.allowLocView.isHidden = true
                }else {
                    self.allowLocView.isHidden = false
                }
                
                self.switchGhostModeBarButton.isUserInteractionEnabled = false
                self.switchCompassBarButton.isUserInteractionEnabled = false
                self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                NetworkConected.internetConect = false
                self.HandleInternetConnection()
            }
        case .wwan:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                
                if !Defaults.isFirstOpenFeed {
                    if Defaults.token != "" {
                        self.privateModelDialogueLbl.text = "Choose who you want to see and be seen by with Private Mode."
                        self.compasslDialogueLbl.text = "Point your phone in any direction; Friendzrs are listed nearest first in that direction."
                        self.sortDialogueLbl.text = "Toggle to sort your Friendzr feed by shared interests."
                    }else {
                        self.privateModelDialogueLbl.text = "You can filter the Feed by the groups you want to see (and be seen by)."
                        self.compasslDialogueLbl.text = "You can sort the Feed by those nearest to you by pointing the phone in any direction."
                        self.sortDialogueLbl.text = "You can sort the Feed by those who share your interests here."
                    }
                    
                    self.showCompassExplainedView.isHidden = false
                    self.showPrivateModeExplainedView.isHidden = true
                    self.showSortByInterestsExplainedView.isHidden = true
                    
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                    self.switchCompassBarButton.isUserInteractionEnabled = false
                    self.switchGhostModeBarButton.isUserInteractionEnabled = false
                }else {
                    self.showCompassExplainedView.isHidden = true
                    self.showPrivateModeExplainedView.isHidden = true
                    self.showSortByInterestsExplainedView.isHidden = true
                    
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                }
                
                NetworkConected.internetConect = true
                
                if self.isCompassOpen {
                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                }else {
                    if self.sortByInterestMatch {
                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                    }else {
                        self.LoadAllFeeds(pageNumber: 1)
                    }
                }
                
                if Defaults.allowMyLocationSettings == true {
                    self.allowLocView.isHidden = true
                }else {
                    self.allowLocView.isHidden = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if Defaults.token != "" {
                        self.updateMyLocation()
                    }
                }
            }
        case .wifi:
            DispatchQueue.main.async {
                self.emptyView.isHidden = true
                self.hideView.isHidden = false
                
                if !Defaults.isFirstOpenFeed {
                    if Defaults.token != "" {
                        self.privateModelDialogueLbl.text = "Choose who you want to see and be seen by with Private Mode."
                        self.compasslDialogueLbl.text = "Point your phone in any direction; Friendzrs are listed nearest first in that direction."
                        self.sortDialogueLbl.text = "Toggle to sort your Friendzr feed by shared interests."
                    }else {
                        self.privateModelDialogueLbl.text = "You can filter the Feed by the groups you want to see (and be seen by)."
                        self.compasslDialogueLbl.text = "You can sort the Feed by those nearest to you by pointing the phone in any direction."
                        self.sortDialogueLbl.text = "You can sort the Feed by those who share your interests here."
                    }
                    
                    self.showCompassExplainedView.isHidden = false
                    self.showPrivateModeExplainedView.isHidden = true
                    self.showSortByInterestsExplainedView.isHidden = true
                    
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                    self.switchCompassBarButton.isUserInteractionEnabled = false
                    self.switchGhostModeBarButton.isUserInteractionEnabled = false
                }else {
                    self.showCompassExplainedView.isHidden = true
                    self.showPrivateModeExplainedView.isHidden = true
                    self.showSortByInterestsExplainedView.isHidden = true
                    
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                }
                
                NetworkConected.internetConect = true
                
                if self.isCompassOpen {
                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                }else {
                    if self.sortByInterestMatch {
                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                    }else {
                        self.LoadAllFeeds(pageNumber: 1)
                    }
                }
                
                if Defaults.allowMyLocationSettings == true {
                    self.allowLocView.isHidden = true
                }else {
                    self.allowLocView.isHidden = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    if Defaults.token != "" {
                        self.updateMyLocation()
                    }
                }
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    @objc func updateFeeds() {
        
        if Defaults.allowMyLocationSettings == true {
            DispatchQueue.main.async {
                if self.isCompassOpen {
                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                }else {
                    if self.sortByInterestMatch {
                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                    }else {
                        self.getAllFeeds(pageNumber: 1)
                    }
                }
            }
            
            self.allowLocView.isHidden = true
            if !Defaults.isFirstOpenFeed {
                
                if Defaults.token != "" {
                    privateModelDialogueLbl.text = "Choose who you want to see and be seen by with Private Mode."
                    compasslDialogueLbl.text = "Point your phone in any direction; Friendzrs are listed nearest first in that direction."
                    sortDialogueLbl.text = "Toggle to sort your Friendzr feed by shared interests."
                }else {
                    privateModelDialogueLbl.text = "You can sort the Feed by those who share your interests here."
                    compasslDialogueLbl.text = "You can sort the Feed by those nearest to you by pointing the phone in any direction."
                    sortDialogueLbl.text = "You can filter the Feed by the groups you want to see (and be seen by)"
                }
                
                
                showCompassExplainedView.isHidden = false
                showPrivateModeExplainedView.isHidden = true
                showSortByInterestsExplainedView.isHidden = true
                
                switchSortedByInterestsButton.isUserInteractionEnabled = false
                switchCompassBarButton.isUserInteractionEnabled = false
                switchGhostModeBarButton.isUserInteractionEnabled = false
            }else {
                showCompassExplainedView.isHidden = true
                showPrivateModeExplainedView.isHidden = true
                showSortByInterestsExplainedView.isHidden = true
                switchSortedByInterestsButton.isUserInteractionEnabled = true
                switchCompassBarButton.isUserInteractionEnabled = true
                switchGhostModeBarButton.isUserInteractionEnabled = true
            }
        }else {
            self.emptyView.isHidden = true
            self.allowLocView.isHidden = false
            switchCompassBarButton.isUserInteractionEnabled = false
            switchGhostModeBarButton.isUserInteractionEnabled = false
            switchSortedByInterestsButton.isUserInteractionEnabled = false
        }
        
        initGhostModeAndSortSwitchButton()
    }
    
    func loadMoreItemsForList(){
        checkLocationPermissionBtns()
        if Defaults.allowMyLocationSettings {
            self.allowLocView.isHidden = true
            currentPage += 1
            
            DispatchQueue.main.async {
                if self.isCompassOpen {
                    self.filterFeedsloadMore(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: self.currentPage)
                }else {
                    if self.sortByInterestMatch {
                        self.filterFeedsloadMore(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: self.currentPage)
                    }else {
                        self.getAllFeeds(pageNumber: self.currentPage)
                    }
                }
            }
        }else {
            self.allowLocView.isHidden = false
        }
    }
    
    func getAllFeeds(pageNumber:Int) {
        hideView.isHidden = true
        viewmodel.getAllUsers(pageNumber: pageNumber)
        viewmodel.feeds.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }
                
                DispatchQueue.main.async {
                    self?.initGhostModeAndSortSwitchButton()
                }
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func LoadAllFeeds(pageNumber:Int) {
        hideView.isHidden = false
        AMShimmer.start(for: hideView)
        viewmodel.getAllUsers(pageNumber: pageNumber)
        
        viewmodel.feeds.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                if Defaults.availableVC == "FeedVC" {
                    DispatchQueue.main.async {
                        self?.hideView.isHidden = true
                        
                    }
                    
                    DispatchQueue.main.async {
                        self?.tableView.delegate = self
                        self?.tableView.dataSource = self
                        self?.tableView.reloadData()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.isLoadingList = false
                        self?.tableView.tableFooterView = nil
                    }
                    
                    DispatchQueue.main.async {
                        self?.initGhostModeAndSortSwitchButton()
                    }
                }
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func filterFeedsBy(isCompassOpen:Bool,degree:Double,sortByInterestMatch:Bool,pageNumber:Int) {
        self.hideView.isHidden = false
        AMShimmer.start(for: hideView)
        viewmodel.filterFeeds(isCompassOpen: isCompassOpen, Bydegree: degree, sortByInterestMatch: sortByInterestMatch, pageNumber: pageNumber)
        viewmodel.feeds.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                DispatchQueue.main.async {
                    self?.hideView.isHidden = true
                }
                
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self?.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self?.switchCompassBarButton.isUserInteractionEnabled = true
                    self?.switchSortedByInterestsButton.isUserInteractionEnabled = true
                }
                
                self?.isSendRequest = false
                DispatchQueue.main.async {
                    self?.initGhostModeAndSortSwitchButton()
                }
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func filterFeedsloadMore(isCompassOpen:Bool,degree:Double,sortByInterestMatch:Bool,pageNumber:Int) {
        self.hideView.isHidden = true
        viewmodel.filterFeeds(isCompassOpen: isCompassOpen, Bydegree: degree, sortByInterestMatch: sortByInterestMatch, pageNumber: pageNumber)
        viewmodel.feeds.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self?.tableView.delegate = self
                self?.tableView.dataSource = self
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self?.isLoadingList = false
                    self?.tableView.tableFooterView = nil
                }
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self?.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self?.switchCompassBarButton.isUserInteractionEnabled = true
                    self?.switchSortedByInterestsButton.isUserInteractionEnabled = true
                }
                
                self?.isSendRequest = false
                DispatchQueue.main.async {
                    self?.initGhostModeAndSortSwitchButton()
                }
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                print(error)
            }
        }
    }
    
    func updateMyLocation() {
        updateLocationVM.updatelocation(ByLat: "\(Defaults.LocationLat)", AndLng: "\(Defaults.LocationLng)") { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let data = data else {return}
            Defaults.LocationLat = data.lat
            Defaults.LocationLng = data.lang
            Defaults.Image = data.userImage
            Defaults.frindRequestNumber = data.frindRequestNumber
            
            NotificationCenter.default.post(name: Notification.Name("updatebadgeInbox"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updateNotificationBadge"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updatebadgeMore"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
        }
    }
    
    //MARK: - Helper
    
    func addCompassView() {
        if Defaults.isIPhoneLessThan2500 {
            let child = UIHostingController(rootView: CompassViewSwiftUIForIPhoneSmall())
            compassContanierView.addSubview(child.view)
            
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
            let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
            let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
            let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
            compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
        }else {
            let child = UIHostingController(rootView: CompassViewSwiftUIForIPhoneSmall2())
            compassContanierView.addSubview(child.view)
            
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
            let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
            let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
            let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
            compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }
    }
    
    //request Ads Tracking authorization
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads here.
                // loadAd()
                DispatchQueue.main.async {
                    self.setupAds()
                }
            })
        } else {
            // Fallback on earlier versions
            DispatchQueue.main.async {
                self.setupAds()
            }
        }
    }
    
    func setupAds() {
        bannerView2 = GADBannerView(adSize: GADAdSizeBanner)
        bannerView2.adUnitID = URLs.adUnitBanner
        bannerView2.rootViewController = self
        bannerView2.load(GADRequest())
        bannerView2.delegate = self
        bannerView2.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(bannerView2)
    }
    
    func setupHideView() {
        for itm in hidesImgs {
            itm.cornerRadiusView(radius: 12)
        }
        
        for item in proImgs {
            item.cornerRadiusForHeight()
        }
    }
    
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        if Defaults.allowMyLocationSettings == true {
            self.allowLocView.isHidden = true
        }else {
            self.allowLocView.isHidden = false
        }
        emptyImg.image = UIImage.init(named: "feednodata_img")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        self.hideView.isHidden = true
        
        if btnsSelected {
            hideView.isHidden = true
            emptyView.isHidden = true
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            hideView.isHidden = true
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            
            emptyImg.image = UIImage.init(named: "feednodata_img")
            emptyLbl.text = "Network is unavailable, please try again!".localizedString
            tryAgainBtn.alpha = 1.0
        }
    }
    
    func pullToRefresh() {
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        print("Refersh")
        currentPage = 1
        btnsSelected = false
        checkLocationPermission()
        self.refreshControl.endRefreshing()
    }
    
    func createFooterView() -> UIView {
        let footerview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let indicatorView = UIActivityIndicatorView()
        indicatorView.center = footerview.center
        footerview.addSubview(indicatorView)
        indicatorView.startAnimating()
        return footerview
    }
    
    func setup() {
        tableView.register(UINib(nibName:cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.register(UINib(nibName:emptyCellID, bundle: nil), forCellReuseIdentifier: emptyCellID)
        tryAgainBtn.cornerRadiusView(radius: 8)
        allowBtn.cornerRadiusView(radius: 8)
        next1Btn.setBorder(color: UIColor.white.cgColor, width: 2)
        next1Btn.cornerRadiusForHeight()
        next2Btn.setBorder(color: UIColor.white.cgColor, width: 2)
        next2Btn.cornerRadiusForHeight()
        next3Btn.setBorder(color: UIColor.white.cgColor, width: 2)
        next3Btn.cornerRadiusForHeight()
        bannerView.setCornerforTop()
    }
    
    //change title for any btns
    func changeTitleBtns(btn:UIButton,title:String) {
        btn.setTitle(title, for: .normal)
    }
    
    func setupCompassContainerView() {
        if isCompassOpen {
            switchCompassBarButton.isOn = true
            if Defaults.isSubscribe == false {
                DispatchQueue.main.async {
                    self.setupAds()
                }
                bannerViewHeight.constant = 50
            }
            else {
                bannerViewHeight.constant = 0
            }
            
            createLocationManager()
            filterDir = true
            filterBtn.isHidden = false
            compassContanierView.isHidden = false
            if Defaults.isIPhoneLessThan2500 {
                compassContainerViewHeight.constant = 200
            }else {
                compassContainerViewHeight.constant = 270
            }
            
            compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
            
        }
        else {
            switchCompassBarButton.isOn = false
            
            if Defaults.isSubscribe == false {
                DispatchQueue.main.async {
                    self.setupAds()
                }
                bannerViewHeight.constant = 50
            }else {
                bannerViewHeight.constant = 0
            }
            
            locationManager.stopUpdatingLocation()
            locationManager.stopUpdatingHeading()
            filterDir = false
            compassContanierView.isHidden = true
            
            filterBtn.isHidden = true
            compassContainerViewHeight.constant = 0
            
            if Defaults.allowMyLocationSettings == true {
                currentPage = 1
                DispatchQueue.main.async {
                    if self.isCompassOpen {
                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: self.currentPage)
                    }else {
                        if self.sortByInterestMatch {
                            self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: self.currentPage)
                        }else {
                            self.LoadAllFeeds(pageNumber: self.currentPage)
                        }
                    }
                }
                
                self.allowLocView.isHidden = true
            }
            else {
                self.emptyView.isHidden = true
                self.allowLocView.isHidden = false
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func next1Btn(_ sender: Any) {
        showCompassExplainedView.isHidden = true
        showPrivateModeExplainedView.isHidden = false
        showSortByInterestsExplainedView.isHidden = true
    }
    
    @IBAction func next2Btn(_ sender: Any) {
        showCompassExplainedView.isHidden = true
        showPrivateModeExplainedView.isHidden = true
        showSortByInterestsExplainedView.isHidden = false
    }
    
    @IBAction func next3Btn(_ sender: Any) {
        showCompassExplainedView.isHidden = true
        showPrivateModeExplainedView.isHidden = true
        showSortByInterestsExplainedView.isHidden = true
        Defaults.isFirstOpenFeed = true
        
        self.switchSortedByInterestsButton.isUserInteractionEnabled = true
        self.switchCompassBarButton.isUserInteractionEnabled = true
        self.switchGhostModeBarButton.isUserInteractionEnabled = true
    }
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
    
    @IBAction func filterBtn(_ sender: Any) {
        self.btnsSelected = true
        if Defaults.token != "" {
            if NetworkConected.internetConect {
                filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: compassDegree, sortByInterestMatch: sortByInterestMatch, pageNumber: 1)
            }
        }else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
    }
    
    @IBAction func allowLocationBtn(_ sender: Any) {
        self.btnsSelected = true
        self.refreshControl.endRefreshing()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                Defaults.allowMyLocationSettings = false
                hideView.isHidden = true
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                switchCompassBarButton.isUserInteractionEnabled = false
                switchGhostModeBarButton.isUserInteractionEnabled = false
                self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                hideView.isHidden = true
                
                if !Defaults.isFirstOpenFeed {
                    
                    if Defaults.token != "" {
                        privateModelDialogueLbl.text = "Choose who you want to see and be seen by with Private Mode."
                        compasslDialogueLbl.text = "Point your phone in any direction; Friendzrs are listed nearest first in that direction."
                        sortDialogueLbl.text = "Toggle to sort your Friendzr feed by shared interests."
                    }else {
                        privateModelDialogueLbl.text = "You can sort the Feed by those who share your interests here."
                        compasslDialogueLbl.text = "You can sort the Feed by those nearest to you by pointing the phone in any direction."
                        sortDialogueLbl.text = "You can filter the Feed by the groups you want to see (and be seen by)"
                    }
                    
                    showCompassExplainedView.isHidden = false
                    showPrivateModeExplainedView.isHidden = true
                    showSortByInterestsExplainedView.isHidden = true
                    switchSortedByInterestsButton.isUserInteractionEnabled = false
                    switchCompassBarButton.isUserInteractionEnabled = false
                    switchGhostModeBarButton.isUserInteractionEnabled = false
                }else {
                    showCompassExplainedView.isHidden = true
                    showPrivateModeExplainedView.isHidden = true
                    showSortByInterestsExplainedView.isHidden = true
                    switchSortedByInterestsButton.isUserInteractionEnabled = true
                    switchCompassBarButton.isUserInteractionEnabled = true
                    switchGhostModeBarButton.isUserInteractionEnabled = true
                }
                
                setupCompassContainerView()
                
                DispatchQueue.main.async {
                    self.updateUserInterface()
                }
                
                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            hideView.isHidden = true
            switchCompassBarButton.isUserInteractionEnabled = false
            switchGhostModeBarButton.isUserInteractionEnabled = false
            switchSortedByInterestsButton.isUserInteractionEnabled = false
            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
            print("\(CLLocationManager.authorizationStatus())")
        }
    }
}

//MARK: - Extensions UITableViewDataSource
extension FeedVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.feeds.value?.data?.count != 0 {
            return viewmodel.feeds.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let actionDate = formatterDate.string(from: Date())
        let actionTime = formatterTime.string(from: Date())
        
        if viewmodel.feeds.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UsersFeedTableViewCell else {return UITableViewCell()}
            let model = viewmodel.feeds.value?.data?[indexPath.row]
            cell.friendRequestNameLbl.text = model?.userName
            cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
            
            
            cell.loaderImg.isHidden = true
            cell.friendRequestImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            if Defaults.token != "" {
                cell.interestMatchPercentLbl.isHidden = false
                cell.progressBarView.isHidden = false
                cell.interestMatchPercentLbl.text = "\(model?.interestMatchPercent ?? 0) % interests match"
                cell.progressBarView.progress = Float(model?.interestMatchPercent ?? 0) / 100
            }else {
                cell.interestMatchPercentLbl.isHidden = true
                cell.progressBarView.isHidden = true
            }
            
            if indexPath.row == 0 {
                cell.upView.isHidden = false
            }else {
                cell.upView.isHidden = false
            }
            
            if indexPath.row == (viewmodel.feeds.value?.data?.count ?? 0) - 1 {
                cell.downView.isHidden = true
            }else {
                cell.downView.isHidden = false
            }
            
            cell.HandleSendRequestBtn = { //send request
                self.btnsSelected = true
                if NetworkConected.internetConect {
                    self.sendUserReuest(model, "\(actionDate) \(actionTime)", cell)
                }
            }
            
            cell.HandleAccseptBtn = { //respond request
                self.btnsSelected = true
                if NetworkConected.internetConect {
                    self.accseptRequest(model, "\(actionDate) \(actionTime)")
                }

            }
            
            cell.HandleRefusedBtn = { // refused request
                self.btnsSelected = true
                if NetworkConected.internetConect {
                    self.refusedRequest(model,"\(actionDate) \(actionTime)")
                }
            }
            
            cell.HandleMessageBtn = { //messages chat
                self.btnsSelected = true
                if NetworkConected.internetConect {
                    guard let vc = UIViewController.viewController(withStoryboard: .Messages, AndContollerID: "MessagesVC") as? MessagesVC else {return}
                    vc.isEvent = false
                    vc.eventChatID = ""
                    vc.chatuserID = model?.userId ?? ""
                    vc.leaveGroup = 1
                    vc.isFriend = true
                    vc.leavevent = 0
                    vc.titleChatImage = model?.image ?? ""
                    vc.titleChatName = model?.userName ?? ""
                    vc.isChatGroupAdmin = false
                    vc.isChatGroup = false
                    vc.groupId = ""
                    vc.isEventAdmin = false
                    CancelRequest.currentTask = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    return
                }
            }
            
            cell.HandleUnblocktBtn = { //unblock account
                self.btnsSelected = true
                if NetworkConected.internetConect {
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 4, requestdate: "\(actionDate) \(actionTime)") { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = message else {return}
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
                        }
                    }
                }else {
                    return
                }
            }
            
            cell.HandleCancelRequestBtn = { // cancel request
                
                self.btnsSelected = true
                
                if NetworkConected.internetConect {
                    self.cancelRequest(model, "\(actionDate) \(actionTime)", cell)
                }
            }
            
            statuskey(model, cell)
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            if Defaults.myAppearanceTypes == [1] {
                cell.controlBtn.isHidden = false
                cell.titleLbl.text = "Turn off private mode to find Friendzrs in your area".localizedString
                cell.emptyImg.image = UIImage(named: "ghostmodenodata_img")
                
                cell.HandleControlBtn = {
                    guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "SettingsVC") as? SettingsVC else {return}
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                cell.controlBtn.isHidden = true
                cell.titleLbl.text = "No Friendzrs are online currently. \nAdjust your settings or check back again later".localizedString
                cell.emptyImg.image = UIImage(named: "feednodata_img")
            }
            
            return cell
        }
    }
}

//MARK: - Extension UITableViewDelegate
extension FeedVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.feeds.value?.data?.count != 0 {
            return 75
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btnsSelected = true
        if Defaults.token != "" {
            if NetworkConected.internetConect {
                if viewmodel.feeds.value?.data?.count != 0 {
                    guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileViewController") as? FriendProfileViewController else {return}
                    vc.userID = viewmodel.feeds.value?.data?[indexPath.row].userId ?? ""
                    //                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    return
                }
            }else {
                return
            }
        }else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView,(scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height, !isLoadingList {
            
            self.isLoadingList = true
            
            if currentPage < viewmodel.feeds.value?.totalPages ?? 0 {
                self.tableView.tableFooterView = self.createFooterView()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    print("self.currentPage >> \(self.currentPage)")
                    self.loadMoreItemsForList()
                }
            }else {
                self.tableView.tableFooterView = nil
                DispatchQueue.main.async {
                    //                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension FeedVC: CLLocationManagerDelegate {
    //Navigation related methods
    // Callback method after successful positioning, as long as the position changes, this method will be called
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Get the latest coordinates
        currLocation = locations.last!
        
        /// Longitude
        let longitudeStr = String(format: "%3.4f", currLocation.coordinate.longitude)
        
        /// Latitude
        let latitudeStr = String(format: "%3.4f", currLocation.coordinate.latitude)
        
        locationLat = currLocation.coordinate.latitude
        locationLng = currLocation.coordinate.longitude
        
        /// Altitude
        let altitudeStr = "\(Int(currLocation.altitude))"
        
        /// East longitude of the new stitching
        let newLongitudeStr = longitudeStr.DegreeToString(d: Double(longitudeStr)!)
        
        /// Newly stitched north latitude
        let newlatitudeStr = latitudeStr.DegreeToString(d: Double(latitudeStr)!)
        
        print("north latitude：\(newlatitudeStr)")
        print("East longitude：\(newLongitudeStr)")
        
        print("North Latitude \(newlatitudeStr)  East Longitude \(newLongitudeStr)")
        print("altitude\(altitudeStr)Meter")
        
        // Anti-geocoding
        /// Create CLGeocoder object
        let geocoder = CLGeocoder()
        
        /*** Reverse geocoding request ***/
        
        // Reverse analysis based on the given latitude and longitude address to get the string address.
        geocoder.reverseGeocodeLocation(currLocation) { (placemarks, error) in
            
            guard let placeM = placemarks else { return }
            // If the analysis is successful, execute the following code
            guard placeM.count > 0 else { return }
            /* placemark: a structure containing all location information */
            // Landmark object containing district, street and other information
            let placemark: CLPlacemark = placeM[0]
            
            /// Store street, province and city information
            let addressDictionary = placemark.postalAddress
            
            /// nation
            guard let country = addressDictionary?.country else { return }
            
            /// city
            guard let city = addressDictionary?.city else { return }
            
            /// Sub location
            guard let subLocality = addressDictionary?.subLocality else { return }
            
            /// Street
            guard let street = addressDictionary?.street else { return }
            
            print("\(country)\(city) \(subLocality) \(street)")
        }
    }
    
    // Obtain the device's geographic and geomagnetic orientation data, so as to turn the geographic scale table and the text label on the table
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        /*
         trueHeading: true north direction
         magneticHeading: magnetic north direction
         */
        /// Get the current device
        let device = UIDevice.current
        
        // 1. Determine whether the current magnetometer angle is valid (if this value is less than 0, the angle is invalid) The smaller the more accurate
        if newHeading.headingAccuracy > 0 {
            
            // 2. Get the current device orientation (magnetic north direction) data
            let magneticHeading: Float = heading(Float(newHeading.magneticHeading), fromOrirntation: device.orientation)
            
            // Geographic heading data: trueHeading
            //let trueHeading: Float = heading(Float(newHeading.trueHeading), fromOrirntation: device.orientation)
            
            /// Geomagnetic north direction
            let headi: Float = -1.0 * Float.pi * Float(newHeading.magneticHeading) / 180.0
            // Set the angle label text
            print("magneticHeading \(Int(magneticHeading))")
            
            compassDegree = Double(magneticHeading)
            Degree.degreeString = "\(Int(magneticHeading))°"
            
            // 3. Rotation transformation
            dScaView.resetDirection(CGFloat(headi))
            
            // 4. The current direction of the mobile phone (camera)
            update(newHeading)
        }
    }
    
    // Determine whether the device needs to be verified, when it is interfered by an external magnetic field
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    // Failed to locate the agent callback
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Positioning failed....\(error)")
    }
    
    /// If the authorization status changes, call
    ///
    ///-Parameters:
    ///-manager: location manager
    ///-status: current authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            print("User undecided")
        case .restricted:
            print("Restricted")
        case .denied:
            // Determine whether the current device supports positioning and whether the positioning service is enabled
            if CLLocationManager.locationServicesEnabled() {
                print("Positioning turned on and rejected")
            }else {
                print("Location service is off")
            }
        case .authorizedAlways:
            print("Front and backstage positioning authorization")
            locationManager.showsBackgroundLocationIndicator = false
        case .authorizedWhenInUse:
            print("Front desk positioning authorization")
        @unknown default:
            fatalError()
        }
    }
    
    
    /// Update the current direction of the mobile phone (camera)
    /// - Parameter newHeading: Towards
    private func update(_ newHeading: CLHeading) {
        
        /// Towards
        let theHeading: CLLocationDirection = newHeading.magneticHeading > 0 ? newHeading.magneticHeading : newHeading.trueHeading
        
        /// angle
        let angle = Int(theHeading)
        
        switch angle {
        case 0:
            print("N")
        case 90:
            print("E")
        case 180:
            print("S")
        case 270:
            print("W")
        default:
            break
        }
        
        if angle > 0 && angle < 90 {
            print("NorthEast")
        }else if angle > 90 && angle < 180 {
            print("SouthEast")
        }else if angle > 180 && angle < 270 {
            print("SouthWest")
        }else if angle > 270 {
            print("NorthWest")
        }
    }
    
    /// Get the current device orientation (magnetic north direction)
    ///
    /// - Parameters:
    ///   - heading: Towards
    ///   - orientation: Device direction
    /// - Returns: Float
    private func heading(_ heading: Float, fromOrirntation orientation: UIDeviceOrientation) -> Float {
        
        var realHeading: Float = heading
        
        switch orientation {
        case .portrait:
            break
        case .portraitUpsideDown:
            realHeading = heading - 180
        case .landscapeLeft:
            realHeading = heading + 90
        case .landscapeRight:
            realHeading = heading - 90
        default:
            break
        }
        if realHeading > 360 {
            realHeading -= 360
        }else if realHeading < 0.0 {
            realHeading += 366
        }
        return realHeading
    }
}

//MARK: - GADBannerViewDelegate
extension FeedVC: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("bannerViewDidReceiveAd")
        //        addBannerViewToView(bannerView2)
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        bannerViewHeight.constant = 0
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("bannerViewDidRecordImpression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillPresentScreen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewWillDIsmissScreen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("bannerViewDidDismissScreen")
    }
}

//MARK: - Navigation right and left btns
extension FeedVC {
    //initCompassSwitchBarButton
    func initCompassSwitchBarButton() {
        switchCompassBarButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        switchCompassBarButton.onTintColor = UIColor.FriendzrColors.primary!
        switchCompassBarButton.setBorder()
        switchCompassBarButton.offTintColor = UIColor.white
        switchCompassBarButton.cornerRadius = 0.5
        switchCompassBarButton.thumbCornerRadius = 0.5
        switchCompassBarButton.animationDuration = 0.25
        switchCompassBarButton.thumbImage = UIImage(named: "compass_ic")
        
        switchCompassBarButton.addTarget(self, action: #selector(handleCompassSwitchBtn), for: .touchUpInside)
        
        switchCompassBarButton.addGestureRecognizer(createCompassSwipeGestureRecognizer(for: .up))
        switchCompassBarButton.addGestureRecognizer(createCompassSwipeGestureRecognizer(for: .down))
        switchCompassBarButton.addGestureRecognizer(createCompassSwipeGestureRecognizer(for: .left))
        switchCompassBarButton.addGestureRecognizer(createCompassSwipeGestureRecognizer(for: .right))
        
        isCompassOpen = false
        
        if Defaults.allowMyLocationSettings == true {
            if isCompassOpen {
                switchCompassBarButton.isOn = true
            }else {
                switchCompassBarButton.isOn = false
            }
        }else {
            isCompassOpen = false
            switchCompassBarButton.isOn = false
        }
        
        let barButton = UIBarButtonItem(customView: switchCompassBarButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleCompassSwitchBtn() {
        print("\(switchCompassBarButton.isOn)")
        btnsSelected = true
        if NetworkConected.internetConect {
            // Azimuth
            if Defaults.allowMyLocationSettings == true {
                if switchCompassBarButton.isOn {
                    self.isCompassOpen = true
                    if Defaults.isSubscribe == false {
                        DispatchQueue.main.async {
                            self.setupAds()
                        }
                        bannerViewHeight.constant = 50
                    }
                    else {
                        bannerViewHeight.constant = 0
                    }
                    
                    createLocationManager()
                    filterDir = true
                    filterBtn.isHidden = false
                    compassContanierView.isHidden = false
                    if Defaults.isIPhoneLessThan2500 {
                        compassContainerViewHeight.constant = 200
                    }else {
                        compassContainerViewHeight.constant = 270
                    }
                    
                    compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
                    
                }
                else {
                    self.isCompassOpen = false
                    if Defaults.isSubscribe == false {
                        DispatchQueue.main.async {
                            self.setupAds()
                        }
                        bannerViewHeight.constant = 50
                    }else {
                        bannerViewHeight.constant = 0
                    }
                    
                    locationManager.stopUpdatingLocation()
                    locationManager.stopUpdatingHeading()
                    filterDir = false
                    compassContanierView.isHidden = true
                    
                    
                    filterBtn.isHidden = true
                    compassContainerViewHeight.constant = 0
                    
                    if Defaults.allowMyLocationSettings == true {
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                            }else {
                                if self.sortByInterestMatch {
                                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                                }else {
                                    self.LoadAllFeeds(pageNumber: 1)
                                }
                            }
                        }
                        self.allowLocView.isHidden = true
                    }
                    else {
                        self.emptyView.isHidden = true
                        self.allowLocView.isHidden = false
                    }
                }
            }
            else {
                self.isCompassOpen = false
                switchCompassBarButton.isOn = false
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                
                if Defaults.isSubscribe == false {
                    DispatchQueue.main.async {
                        self.setupAds()
                    }
                    bannerViewHeight.constant = 50
                }else {
                    bannerViewHeight.constant = 0
                }
                
            }
            
        }
    }
    
    private func createCompassSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didCompassSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    @objc private func didCompassSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        
        switch sender.direction {
        case .up:
            break
        case .down:
            break
        case .left:
            btnsSelected = true
            if NetworkConected.internetConect {
                if Defaults.allowMyLocationSettings == true {
                    switchCompassBarButton.isOn = false
                    self.isCompassOpen = false
                    if Defaults.isSubscribe == false {
                        DispatchQueue.main.async {
                            self.setupAds()
                        }
                        bannerViewHeight.constant = 50
                    }else {
                        bannerViewHeight.constant = 0
                    }
                    
                    locationManager.stopUpdatingLocation()
                    locationManager.stopUpdatingHeading()
                    filterDir = false
                    compassContanierView.isHidden = true
                    
                    
                    filterBtn.isHidden = true
                    compassContainerViewHeight.constant = 0
                    
                    if Defaults.allowMyLocationSettings == true {
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                            }else {
                                if self.sortByInterestMatch {
                                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                                }else {
                                    self.LoadAllFeeds(pageNumber: 1)
                                }
                            }
                        }
                        self.allowLocView.isHidden = true
                    }else {
                        self.emptyView.isHidden = true
                        self.allowLocView.isHidden = false
                    }
                }
                else {
                    self.isCompassOpen = false
                    switchCompassBarButton.isOn = false
                    createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                    initCompassSwitchBarButton()
                    if Defaults.isSubscribe == false {
                        DispatchQueue.main.async {
                            self.setupAds()
                        }
                        bannerViewHeight.constant = 50
                    }else {
                        bannerViewHeight.constant = 0
                    }
                }
            }
        case .right:
            btnsSelected = true
            if NetworkConected.internetConect {
                if Defaults.allowMyLocationSettings == true {
                    switchCompassBarButton.isOn = true
                    
                    self.isCompassOpen = true
                    if Defaults.isSubscribe == false {
                        DispatchQueue.main.async {
                            self.setupAds()
                        }
                        bannerViewHeight.constant = 50
                    }else {
                        bannerViewHeight.constant = 0
                    }
                    createLocationManager()
                    filterDir = true
                    filterBtn.isHidden = false
                    compassContanierView.isHidden = false
                    if Defaults.isIPhoneLessThan2500 {
                        compassContainerViewHeight.constant = 200
                    }else {
                        compassContainerViewHeight.constant = 270
                    }
                    
                    compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
                }
                else {
                    self.isCompassOpen = false
                    switchCompassBarButton.isOn = false
                    createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                    initCompassSwitchBarButton()
                    if Defaults.isSubscribe == false {
                        DispatchQueue.main.async {
                            self.setupAds()
                        }
                        bannerViewHeight.constant = 50
                    }else {
                        bannerViewHeight.constant = 0
                    }
                    
                }
                
            }
        default:
            break
        }
        
        print("\(switchCompassBarButton.isOn)")
    }
    
    //initGhostModeAndSortSwitchButton
    func initGhostModeAndSortSwitchButton() {
        switchGhostModeBarButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        switchGhostModeBarButton.onTintColor = UIColor.FriendzrColors.primary!
        switchGhostModeBarButton.setBorder()
        switchGhostModeBarButton.offTintColor = UIColor.white
        switchGhostModeBarButton.cornerRadius = 0.5
        switchGhostModeBarButton.thumbCornerRadius = 0.5
        switchGhostModeBarButton.animationDuration = 0.25
        switchGhostModeBarButton.isOn = Defaults.ghostMode
        
        if switchGhostModeBarButton.isOn {
            self.switchGhostModeBarButton.thumbImage = UIImage(named: "privatemode-on-ic")
        }else {
            self.switchGhostModeBarButton.thumbImage = UIImage(named: "privatemode-off-ic")
        }
        
        switchGhostModeBarButton.addTarget(self, action:  #selector(handleGhostModeSwitchBtn), for: .allEvents)
        
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .up))
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .down))
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .left))
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .right))
        let barButton = UIBarButtonItem(customView: switchGhostModeBarButton)
        
        
        switchSortedByInterestsButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        switchSortedByInterestsButton.onTintColor = UIColor.FriendzrColors.primary!
        switchSortedByInterestsButton.setBorder()
        switchSortedByInterestsButton.offTintColor = UIColor.white
        switchSortedByInterestsButton.cornerRadius = 0.5
        switchSortedByInterestsButton.thumbCornerRadius = 0.5
        switchSortedByInterestsButton.animationDuration = 0.25
        
        switchSortedByInterestsButton.isOn = self.sortByInterestMatch
        
        self.switchSortedByInterestsButton.thumbImage = UIImage(named: "filterFeedByInterests_ic")
        switchSortedByInterestsButton.addTarget(self, action:  #selector(handleSortedByInterestsSwitchBtn), for: .touchUpInside)
        
        switchSortedByInterestsButton.addGestureRecognizer(createSortedByInterestsSwipeGestureRecognizer(for: .up))
        switchSortedByInterestsButton.addGestureRecognizer(createSortedByInterestsSwipeGestureRecognizer(for: .down))
        switchSortedByInterestsButton.addGestureRecognizer(createSortedByInterestsSwipeGestureRecognizer(for: .left))
        switchSortedByInterestsButton.addGestureRecognizer(createSortedByInterestsSwipeGestureRecognizer(for: .right))
        let barButton2 = UIBarButtonItem(customView: switchSortedByInterestsButton)
        
        self.navigationItem.leftBarButtonItems = [barButton,barButton2]
    }
    
    private func createGhostModeSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didGhostModeSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    @objc private func didGhostModeSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        switch sender.direction {
        case .up:
            break
        case .down:
            break
        case .left:
            btnsSelected = true
            handlePrivateModeSwitchBtn()
        case .right:
            self.btnsSelected = true
            handlePrivateModeSwitchBtn()
        default:
            break
        }
        
        print("\(switchCompassBarButton.isOn)")
    }
    
    func handlePrivateModeSwitchBtn() {
        if NetworkConected.internetConect {
            if Defaults.ghostMode == false {
                self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                DispatchQueue.main.async {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = false
                    self.switchCompassBarButton.isUserInteractionEnabled = false
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                }
                
                self.alertView?.parentVC = self
                
                self.alertView?.selectedHideType.removeAll()
                self.alertView?.typeIDs.removeAll()
                self.alertView?.typeStrings.removeAll()
                SelectedSingleTone.isSelected = false
                
                for item in self.alertView?.hideArray ?? [] {
                    item.isSelected = false
                    self.alertView?.tableView.reloadData()
                }
                
                self.alertView?.onTypesCallBackResponse = self.onHideGhostModeTypesCallBack
                
                //cancel view
                self.alertView?.HandlehideViewBtn = {
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                        self.switchGhostModeBarButton.isUserInteractionEnabled = true
                        self.switchCompassBarButton.isUserInteractionEnabled = true
                        self.switchSortedByInterestsButton.isUserInteractionEnabled = true
                        self.initGhostModeAndSortSwitchButton()
                    }
                }
                
                self.alertView?.HandleSaveBtn = {
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                        self.switchGhostModeBarButton.isUserInteractionEnabled = true
                        self.switchCompassBarButton.isUserInteractionEnabled = true
                        self.switchSortedByInterestsButton.isUserInteractionEnabled = true
                        self.initGhostModeAndSortSwitchButton()
                    }
                }
                
                self.view.addSubview((self.alertView)!)
            }
            else {
                self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                
                self.showAlertView?.titleLbl.text = "Confirm?".localizedString
                self.showAlertView?.detailsLbl.text = "Are you sure you want to turn off private mode?".localizedString
                
                DispatchQueue.main.async {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = false
                    self.switchCompassBarButton.isUserInteractionEnabled = false
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                }
                
                self.showAlertView?.HandleConfirmBtn = {
                    self.btnsSelected = true
                    if NetworkConected.internetConect {
                        self.settingVM.toggleGhostMode(ghostMode: false, myAppearanceTypes: [0], completion: { error, data in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard data != nil else {return}
                            DispatchQueue.main.async {
                                Defaults.ghostMode = false
                                Defaults.ghostModeEveryOne = false
                                Defaults.myAppearanceTypes = [0]
                                self.switchGhostModeBarButton.isOn = false
                                self.switchGhostModeBarButton.thumbImage = UIImage(named: "privatemode-off-ic")
                            }
                            
                            DispatchQueue.main.async {
                                if self.isCompassOpen {
                                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                                }else {
                                    if self.sortByInterestMatch {
                                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                                    }else {
                                        self.LoadAllFeeds(pageNumber: 1)
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("updateSettings"), object: nil, userInfo: nil)
                            }
                        })
                    }
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                            self.switchGhostModeBarButton.isUserInteractionEnabled = true
                            self.switchCompassBarButton.isUserInteractionEnabled = true
                            self.switchSortedByInterestsButton.isUserInteractionEnabled = true
                            self.initGhostModeAndSortSwitchButton()
                        }
                        
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.showAlertView?.HandleCancelBtn = {
                    DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                        self.initGhostModeAndSortSwitchButton()
                        self.switchGhostModeBarButton.isUserInteractionEnabled = true
                        self.switchCompassBarButton.isUserInteractionEnabled = true
                        self.switchSortedByInterestsButton.isUserInteractionEnabled = true
                    }
                }
                
                self.view.addSubview((self.showAlertView)!)
            }
        }
        else {
            HandleInternetConnection()
            self.switchGhostModeBarButton.isOn = Defaults.ghostMode
        }
        
    }
    
    @objc func handleGhostModeSwitchBtn() {
        btnsSelected = true
        handlePrivateModeSwitchBtn()
    }
    
    func onHideGhostModeTypesCallBack(_ data: [String], _ value: [Int]) -> () {
        print(data)
        print(value)
        if Defaults.token != "" {
            ghostModeToggle(ghostMode: true, myAppearanceTypes:value)
        }
        else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
    }
    
    //ghostmode toggle
    func ghostModeToggle(ghostMode:Bool,myAppearanceTypes:[Int]) {
        self.settingVM.toggleGhostMode(ghostMode: ghostMode, myAppearanceTypes: myAppearanceTypes) { error, data in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard data != nil else {
                return
            }
            
            Defaults.ghostMode = data?.ghostmode ?? true
            Defaults.myAppearanceTypes = data?.myAppearanceTypes ?? [1]
            
            DispatchQueue.main.async {
                if data?.ghostmode == true {
                    if data?.myAppearanceTypes == [1] {
                        Defaults.ghostModeEveryOne = true
                    }else {
                        Defaults.ghostModeEveryOne = false
                    }
                    self.switchGhostModeBarButton.isOn = true
                    self.switchGhostModeBarButton.thumbImage = UIImage(named: "privatemode-on-ic")
                }else {
                    Defaults.ghostModeEveryOne = false
                    Defaults.ghostMode = false
                    self.switchGhostModeBarButton.isOn = false
                    self.switchGhostModeBarButton.thumbImage = UIImage(named: "privatemode-off-ic")
                }
            }
            
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                self.switchGhostModeBarButton.isUserInteractionEnabled = true
                self.switchCompassBarButton.isUserInteractionEnabled = true
                self.switchSortedByInterestsButton.isUserInteractionEnabled = true
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateSettings"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
        }
    }
    
    @objc func handleSortedByInterestsSwitchBtn() {
        print("handleSortedByInterestsSwitchBtn")
        if Defaults.token != "" {
            currentPage = 1
            
            if switchSortedByInterestsButton.isOn {
                self.sortByInterestMatch = true
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = false
                    self.switchCompassBarButton.isUserInteractionEnabled = false
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                }
                
                self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: currentPage)
            }
            else {
                self.sortByInterestMatch = false
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1) {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = false
                    self.switchCompassBarButton.isUserInteractionEnabled = false
                    self.switchSortedByInterestsButton.isUserInteractionEnabled = false
                }
                
                if isCompassOpen {
                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: currentPage)
                }else {
                    self.LoadAllFeeds(pageNumber: currentPage)
                }
            }
        }
        else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
    }
    
    private func createSortedByInterestsSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSortByInterestsSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    @objc private func didSortByInterestsSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .up:
            break
        case .down:
            break
        case .left:
            if Defaults.token != "" {
                if switchSortedByInterestsButton.isOn {
                    self.sortByInterestMatch = true
                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                }else {
                    self.sortByInterestMatch = false
                    if isCompassOpen {
                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                    }else {
                        self.LoadAllFeeds(pageNumber: 1)
                    }
                }
            }
            else {
                Router().toOptionsSignUpVC(IsLogout: false)
            }
            break
        case .right:
            if Defaults.token != "" {
                if switchSortedByInterestsButton.isOn {
                    self.sortByInterestMatch = true
                    self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                }else {
                    self.sortByInterestMatch = false
                    if isCompassOpen {
                        self.filterFeedsBy(isCompassOpen: self.isCompassOpen, degree: self.compassDegree, sortByInterestMatch: self.sortByInterestMatch, pageNumber: 1)
                    }else {
                        self.LoadAllFeeds(pageNumber: 1)
                    }
                }
            }
            else {
                Router().toOptionsSignUpVC(IsLogout: false)
            }
            break
        default:
            break
        }
    }
}

//MARK: - Cell Btns Action
extension FeedVC {
    func statuskey(_ model: UserFeedObj?,_ cell: UsersFeedTableViewCell) {
        //status key
        switch model?.key {
        case 0:
            //Status = normal case
            cell.subStackView.isHidden = true
            cell.superStackView.isHidden = false
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = false
            cell.messageBtn.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 1:
            //Status = I have added a friend request
            cell.subStackView.isHidden = true
            cell.superStackView.isHidden = false
            cell.cancelRequestBtn.isHidden = false
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 2:
            //Status = Send me a request to add a friend
            cell.subStackView.isHidden = false
            cell.superStackView.isHidden = true
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 3:
            //Status = We are friends
            cell.subStackView.isHidden = true
            cell.superStackView.isHidden = false
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = false
            cell.unblockBtn.isHidden = true
            break
        case 4:
            //Status = I block user
            cell.subStackView.isHidden = true
            cell.superStackView.isHidden = false
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unblockBtn.isHidden = false
            break
        case 5:
            //Status = user block me
            cell.subStackView.isHidden = true
            cell.superStackView.isHidden = false
            cell.cancelRequestBtn.isHidden = true
            cell.sendRequestBtn.isHidden = true
            cell.messageBtn.isHidden = true
            cell.unblockBtn.isHidden = true
            break
        case 6:
            break
        default:
            break
        }
    }
    func sendUserReuest(_ model: UserFeedObj?, _ requestdate:String, _ cell: UsersFeedTableViewCell) {
        self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Sending...".localizedString)
        cell.sendRequestBtn.isUserInteractionEnabled = false
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1,requestdate: requestdate) { error, message in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            DispatchQueue.main.async {
                cell.sendRequestBtn.isHidden = true
                cell.sendRequestBtn.setTitle("Send Request", for: .normal)
                cell.sendRequestBtn.isUserInteractionEnabled = true
                cell.cancelRequestBtn.isHidden = false
                
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
            }
        }
    }
    
    func accseptRequest(_ model: UserFeedObj?, _ requestdate:String) {
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2, requestdate: requestdate) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
        }
    }
    func refusedRequest(_ model: UserFeedObj?, _ requestdate:String) {
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6, requestdate: requestdate) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
        }
    }
    
    func cancelRequest(_ model: UserFeedObj?, _ requestdate:String, _ cell: UsersFeedTableViewCell) {
        self.changeTitleBtns(btn: cell.cancelRequestBtn, title: "Canceling...".localizedString)
        cell.cancelRequestBtn.isUserInteractionEnabled = false
        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6, requestdate: requestdate) { error, message in
            if let error = error {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
                return
            }
            
            guard let _ = message else {return}
            
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    cell.cancelRequestBtn.isHidden = true
                    cell.cancelRequestBtn.setTitle("Cancel Request", for: .normal)
                    cell.sendRequestBtn.isHidden = false
                    cell.cancelRequestBtn.isUserInteractionEnabled = true
                }
                
                Defaults.frindRequestNumber -= 1
                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updatebadgeRequests"), object: nil, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("updateInitRequestsBarButton"), object: nil, userInfo: nil)
            }
        }
    }
}
