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

let screenH: CGFloat = UIScreen.main.bounds.height
let screenW: CGFloat = UIScreen.main.bounds.width

extension FeedVC {
    func checkLocationPermission() {
        self.refreshControl.endRefreshing()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                Defaults.allowMyLocationSettings = false
                hideView.isHidden = true
                NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                hideView.isHidden = true
                DispatchQueue.main.async {
                    self.updateUserInterface()
                }
            default:
                break
            }
        }else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            hideView.isHidden = true
            NotificationCenter.default.post(name: Notification.Name("updateFeeds"), object: nil, userInfo: nil)
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
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
}

class FeedVC: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tryAgainBtn: UIButton!
    @IBOutlet weak var emptyLbl: UILabel!
    @IBOutlet weak var emptyImg: UIImageView!
    @IBOutlet weak var compassContanierView: UIView!
    @IBOutlet weak var compassContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var allowLocView: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var filterHideView: UIView!
    @IBOutlet weak var dialogimg: UIImageView!
    @IBOutlet weak var allowBtn: UIButton!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var hideView: UIView!
    @IBOutlet var hidesImgs: [UIImageView]!
    @IBOutlet var proImgs: [UIImageView]!
    
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
    
    private func createLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 0
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.headingAvailable() {
            locationManager.startUpdatingLocation()     //Start location service
            locationManager.startUpdatingHeading()      //Start getting device orientation
            print("Start Positioning")
        }else {
            print("Cannot get heading data")
        }
    }
    
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
    var btnsSelected:Bool = false
    var internetConnect:Bool = false
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    
    var isSendRequest:Bool = false
    
    var locationLat = 0.0
    var locationLng = 0.0
    
    var isCompassOpen:Bool = false
    var isPrivateModesOpen:Bool = false
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed".localizedString
        initCompassSwitchBarButton()
        pullToRefresh()
        addCompassView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeeds), name: Notification.Name("updateFeeds"), object: nil)
        
        seyupAds()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
        Defaults.availableVC = "FeedVC"
        print("availableVC >> \(Defaults.availableVC)")

        filterDir = switchCompassBarButton.isOn
        CancelRequest.currentTask = false
        initGhostModeSwitchButton()
        setupHideView()
        
        self.checkLocationPermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hideLoading()
        CancelRequest.currentTask = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addCompassView() {
        if Defaults.isIPhoneSmall {
            let child = UIHostingController(rootView: CompassViewSwiftUIForIPhoneSmall())
            compassContanierView.addSubview(child.view)
            
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
            let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
            let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
            let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
            compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
            
        }else {
            let child = UIHostingController(rootView: CompassViewSwiftUI())
            compassContanierView.addSubview(child.view)
            
            child.view.translatesAutoresizingMaskIntoConstraints = false
            let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
            let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
            let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
            let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
            compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        }
    }
    
    func seyupAds() {
        bannerView.adUnitID =  URLs.adUnitBanner
        //        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.setCornerforTop()
    }
    
    //MARK:- APIs
    @objc func updateFeeds() {
        if Defaults.allowMyLocationSettings == true {
            DispatchQueue.main.async {
                if self.isCompassOpen {
                    self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                }else {
                    self.getAllFeeds(pageNumber: 0)
                }
            }
            self.allowLocView.isHidden = true
        }else {
            self.emptyView.isHidden = true
            self.allowLocView.isHidden = false
        }
        
        initGhostModeSwitchButton()
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        if self.isCompassOpen {
            self.filterFeedsBy(degree: compassDegree, pageNumber: currentPage)
        }else {
            self.getAllFeeds(pageNumber: currentPage)
        }
    }
    
    func getAllFeeds(pageNumber:Int) {
        hideView.hideLoader()
        viewmodel.getAllUsers(pageNumber: pageNumber)
        viewmodel.feeds.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                DispatchQueue.main.async {
                    hideView.hideLoader()
                }
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { error in
            DispatchQueue.main.async {
                self.hideLoading()
                print(error)
            }
        }
    }
    
    func LoadAllFeeds(pageNumber:Int) {
        hideView.isHidden = false
        hideView.showLoader()
        viewmodel.getAllUsers(pageNumber: pageNumber)
        viewmodel.feeds.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                DispatchQueue.main.async {
                    hideView.hideLoader()
                    hideView.isHidden = true
                }
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { error in
            DispatchQueue.main.async {
                self.hideLoading()
                print(error)
            }
        }
    }
    
    func filterFeedsBy(degree:Double,pageNumber:Int) {
        self.hideView.isHidden = false
        self.hideView.showLoader()
        viewmodel.filterFeeds(Bydegree: degree, pageNumber: pageNumber)
        viewmodel.feeds.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                DispatchQueue.main.async {
                    self.hideView.isHidden = true
                    self.hideView.hideLoader()
                }
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.tableView.tableFooterView = nil
                
                isSendRequest = false
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
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
        }
    }
    
    //MARK: - Helper
    func setupHideView() {
        for itm in hidesImgs {
            itm.cornerRadiusView(radius: 6)
        }
        
        for item in proImgs {
            item.cornerRadiusForHeight()
        }
    }
    
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            self.hideView.isHidden = true
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            internetConnect = true
            
            if isCompassOpen {
                filterFeedsBy(degree: compassDegree, pageNumber: 1)
            }else {
                LoadAllFeeds(pageNumber: 0)
            }
            
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                self.updateMyLocation()
            }
        case .wifi:
            self.emptyView.isHidden = true
            self.hideView.isHidden = false
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            internetConnect = true
            
            if isCompassOpen {
                filterFeedsBy(degree: compassDegree, pageNumber: 0)
            }else {
                LoadAllFeeds(pageNumber: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                self.updateMyLocation()
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func updateNetworkForBtns() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            self.hideView.isHidden = true
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            self.hideView.isHidden = true
            internetConnect = true
        case .wifi:
            self.emptyView.isHidden = true
            self.hideView.isHidden = true
            internetConnect = true
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    func HandleinvalidUrl() {
        emptyView.isHidden = false
        if Defaults.allowMyLocationSettings == true {
            self.allowLocView.isHidden = true
        }else {
            self.allowLocView.isHidden = false
        }
        emptyImg.image = UIImage.init(named: "maskGroup9")
        emptyLbl.text = "sorry for that we have some maintaince with our servers please try again in few moments".localizedString
        tryAgainBtn.alpha = 1.0
    }
    
    func HandleInternetConnection() {
        if btnsSelected {
            emptyView.isHidden = true
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            self.view.makeToast("Network is unavailable, please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            if Defaults.allowMyLocationSettings == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No available network, please try again!".localizedString
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
        checkLocationPermission()
//        DispatchQueue.main.async {
//            self.updateUserInterface()
//        }
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
        nextBtn.setBorder(color: UIColor.white.cgColor, width: 2)
        nextBtn.cornerRadiusForHeight()
    }
    
    //change title for any btns
    func changeTitleBtns(btn:UIButton,title:String) {
        btn.setTitle(title, for: .normal)
    }
    
    //MARK: - Actions
    @IBAction func nextBtn(_ sender: Any) {
        filterHideView.isHidden = true
        Defaults.isFirstFilter = true
        
        createLocationManager()
        filterDir = true
        filterBtn.isHidden = false
        compassContanierView.isHidden = false
        compassContainerViewHeight.constant = 320
    }
    
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }
    
    @IBAction func filterBtn(_ sender: Any) {
        filterFeedsBy(degree: compassDegree, pageNumber: 1)
    }
    
    @IBAction func allowLocationBtn(_ sender: Any) {
        self.refreshControl.endRefreshing()
        self.checkLocationPermission()
    }
}

//MARK: - Extensions
extension FeedVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewmodel.feeds.value?.data?.count != 0 {
            return viewmodel.feeds.value?.data?.count ?? 0
        }else {
            return 1
        }
    }
    
    func statuskey(_ model: UserFeedObj?, _ cell: UsersFeedTableViewCell) {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewmodel.feeds.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UsersFeedTableViewCell else {return UITableViewCell()}
            let model = viewmodel.feeds.value?.data?[indexPath.row]
            cell.friendRequestNameLbl.text = model?.userName
            cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
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
                self.updateNetworkForBtns()
                if self.internetConnect {
                    self.changeTitleBtns(btn: cell.sendRequestBtn, title: "Sending...".localizedString)
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1) { error, message in
                        
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
                            NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(degree: self.compassDegree, pageNumber: 1)
                            }else {
                                self.getAllFeeds(pageNumber: 1)
                            }
                        }
                    }
                }
            }
            
            cell.HandleAccseptBtn = { //respond request
                
                self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.showAlertView?.titleLbl.text = "Confirm?".localizedString
                self.showAlertView?.detailsLbl.text = "Are you sure you want to accept this request?".localizedString
                
                self.showAlertView?.HandleConfirmBtn = {
                    self.btnsSelected = true
                    self.updateNetworkForBtns()
                    
                    if self.internetConnect {
                        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = message else {return}
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                            }
                            
                            DispatchQueue.main.async {
                                if self.isCompassOpen {
                                    self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                                }else {
                                    self.getAllFeeds(pageNumber: 0)
                                }
                            }
                        }
                    }
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.view.addSubview((self.showAlertView)!)
            }
            
            cell.HandleRefusedBtn = { // refused request
                self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.showAlertView?.titleLbl.text = "Confirm?".localizedString
                self.showAlertView?.detailsLbl.text = "Are you sure you want to refuse this request?"
                
                self.showAlertView?.HandleConfirmBtn = {
                    self.btnsSelected = true
                    self.updateNetworkForBtns()
                    
                    if self.internetConnect {
                        self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.view.makeToast(error)
                                }
                                return
                            }
                            
                            guard let _ = message else {return}
                            
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                            }
                            
                            DispatchQueue.main.async {
                                if self.isCompassOpen {
                                    self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                                }else {
                                    self.getAllFeeds(pageNumber: 0)
                                }
                                
                            }
                        }
                    }
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.view.addSubview((self.showAlertView)!)
            }
            
            cell.HandleMessageBtn = { //messages chat
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.self.internetConnect {
                    Router().toConversationVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: model?.userId ?? "", isFriend: true, titleChatImage: model?.image ?? "", titleChatName: model?.userName ?? "", isChatGroupAdmin: false, isChatGroup: false, groupId: "",leaveGroup: 1, isEventAdmin: false)
                }else {
                    return
                }
            }
            
            cell.HandleUnblocktBtn = { //unblock account
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 4) { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = message else {return}
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                            }else {
                                self.getAllFeeds(pageNumber: 0)
                            }
                            
                        }
                    }
                }else {
                    return
                }
            }
            
            cell.HandleCancelRequestBtn = { // cancel request
                
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.changeTitleBtns(btn: cell.cancelRequestBtn, title: "Canceling...".localizedString)
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard let _ = message else {return}
                        
                        DispatchQueue.main.async {
                            cell.cancelRequestBtn.isHidden = true
                            cell.cancelRequestBtn.setTitle("Cancel Request", for: .normal)
                            NotificationCenter.default.post(name: Notification.Name("updateResquests"), object: nil, userInfo: nil)
                        }
                        
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                            }else {
                                self.getAllFeeds(pageNumber: 0)
                            }
                            
                        }
                    }
                }
            }
            
            statuskey(model, cell)
            
            return cell
        }
        
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            if Defaults.myAppearanceTypes == [1] {
                cell.controlBtn.isHidden = false
                cell.titleLbl.text = "Turn off private modes to see friendzrs".localizedString
                cell.emptyImg.image = UIImage(named: "ghostImg")
                
                cell.HandleControlBtn = {
                    guard let vc = UIViewController.viewController(withStoryboard: .More, AndContollerID: "SettingsVC") as? SettingsVC else {return}
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                cell.controlBtn.isHidden = true
                cell.titleLbl.text = "You haven't any data yet".localizedString
                cell.emptyImg.image = UIImage(named: "emptyImage")
            }
            
            return cell
        }
    }
}

//extension Table View Delegate
extension FeedVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.feeds.value?.data?.count != 0 {
            return 75
        }else {
            return 350
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        btnsSelected = true
        updateNetworkForBtns()
        
        if internetConnect {
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
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
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
                    self.view.makeToast("No more data".localizedString)
                }
                return
            }
        }
    }
}

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

extension FeedVC:GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print(error)
        bannerViewHeight.constant = 0
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

extension FeedVC {
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
        
        // Azimuth
        if Defaults.allowMyLocationSettings == true {
            if switchCompassBarButton.isOn {
                self.isCompassOpen = true
                bannerViewHeight.constant = 50
                if !Defaults.isFirstFilter {
                    filterHideView.isHidden = false
                    Defaults.isFirstFilter = true
                }else {
                    filterHideView.isHidden = true
                    Defaults.isFirstFilter = true
                    
                    createLocationManager()
                    filterDir = true
                    filterBtn.isHidden = false
                    compassContanierView.isHidden = false
                    if Defaults.isIPhoneSmall {
                        compassContainerViewHeight.constant = 200
                    }else {
                        compassContainerViewHeight.constant = 320
                    }
                    
                    compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
                }
            }else {
                self.isCompassOpen = false
                filterHideView.isHidden = true
                Defaults.isFirstFilter = true
                bannerViewHeight.constant = 100
                
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
                filterDir = false
                compassContanierView.isHidden = true
                
                
                filterBtn.isHidden = true
                compassContainerViewHeight.constant = 0
                
                if Defaults.allowMyLocationSettings == true {
                    DispatchQueue.main.async {
                        if self.isCompassOpen {
                            self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                        }else {
                            self.getAllFeeds(pageNumber: 0)
                        }
                        
                    }
                    self.allowLocView.isHidden = true
                }else {
                    self.emptyView.isHidden = true
                    self.allowLocView.isHidden = false
                }
            }
        }
        else {
            self.isCompassOpen = false
            switchCompassBarButton.isOn = false
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
            bannerViewHeight.constant = 100
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
            if Defaults.allowMyLocationSettings == true {
                switchCompassBarButton.isOn = false
                self.isCompassOpen = false
                filterHideView.isHidden = true
                Defaults.isFirstFilter = true
                bannerViewHeight.constant = 100
                
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
                filterDir = false
                compassContanierView.isHidden = true
                
                
                filterBtn.isHidden = true
                compassContainerViewHeight.constant = 0
                
                if Defaults.allowMyLocationSettings == true {
                    DispatchQueue.main.async {
                        if self.isCompassOpen {
                            self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                        }else {
                            self.getAllFeeds(pageNumber: 0)
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
                //                self.showAlert(withMessage: "Please allow your location".localizedString)
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                initCompassSwitchBarButton()
                bannerViewHeight.constant = 100
            }
            //            break
        case .right:
            if Defaults.allowMyLocationSettings == true {
                switchCompassBarButton.isOn = true
                
                self.isCompassOpen = true
                bannerViewHeight.constant = 50
                if !Defaults.isFirstFilter {
                    filterHideView.isHidden = false
                    Defaults.isFirstFilter = true
                }else {
                    filterHideView.isHidden = true
                    Defaults.isFirstFilter = true
                    
                    createLocationManager()
                    filterDir = true
                    filterBtn.isHidden = false
                    compassContanierView.isHidden = false
                    if Defaults.isIPhoneSmall {
                        compassContainerViewHeight.constant = 200
                    }else {
                        compassContainerViewHeight.constant = 320
                    }
                    
                    compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
                }
            }
            else {
                self.isCompassOpen = false
                switchCompassBarButton.isOn = false
                //                self.showAlert(withMessage: "Please allow your location".localizedString)
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                initCompassSwitchBarButton()
                bannerViewHeight.constant = 100
            }
        default:
            break
        }
        
        print("\(switchCompassBarButton.isOn)")
    }
    
    
    
    func initGhostModeSwitchButton() {
        switchGhostModeBarButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        switchGhostModeBarButton.onTintColor = UIColor.FriendzrColors.primary!
        switchGhostModeBarButton.setBorder()
        switchGhostModeBarButton.offTintColor = UIColor.white
        switchGhostModeBarButton.cornerRadius = 0.5
        switchGhostModeBarButton.thumbCornerRadius = 0.5
        switchGhostModeBarButton.animationDuration = 0.25
        switchGhostModeBarButton.thumbImage = UIImage(named: "ghostModeSwitch_ic")
        
        if Defaults.ghostMode == true {
            switchGhostModeBarButton.isOn = true
        }else {
            switchGhostModeBarButton.isOn = false
        }
        
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .up))
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .down))
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .left))
        switchGhostModeBarButton.addGestureRecognizer(createGhostModeSwipeGestureRecognizer(for: .right))
        
        switchGhostModeBarButton.addTarget(self, action:  #selector(handleGhostModeSwitchBtn), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: switchGhostModeBarButton)
        self.navigationItem.leftBarButtonItem = barButton
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
            self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            self.showAlertView?.titleLbl.text = "Confirm?".localizedString
            self.showAlertView?.detailsLbl.text = "Are you sure you want to turn off private modes?".localizedString
            
            self.showAlertView?.HandleConfirmBtn = {
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.settingVM.toggleGhostMode(ghostMode: false, myAppearanceTypes: [0], completion: { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard data != nil else {return}
                        Defaults.ghostMode = false
                        Defaults.ghostModeEveryOne = false
                        Defaults.myAppearanceTypes = [0]
                        
                        DispatchQueue.main.async {
                            //                            self.switchGhostModeBarButton.isOn = false
                            self.initGhostModeSwitchButton()
                        }
                        
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                            }else {
                                self.getAllFeeds(pageNumber: 0)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateSettings"), object: nil, userInfo: nil)
                        }
                    })
                }
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    DispatchQueue.main.async {
                        self.switchGhostModeBarButton.isUserInteractionEnabled = true
                        self.switchCompassBarButton.isUserInteractionEnabled = true
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
                DispatchQueue.main.async {
                    self.initGhostModeSwitchButton()
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                }
            }
            
            self.view.addSubview((self.showAlertView)!)
            
        case .right:
            self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            DispatchQueue.main.async {
                self.switchGhostModeBarButton.isUserInteractionEnabled = false
                self.switchCompassBarButton.isUserInteractionEnabled = false
            }
            
            self.alertView?.parentVC = self
            
            self.alertView?.selectedHideType.removeAll()
            self.alertView?.typeIDs.removeAll()
            self.alertView?.typeStrings.removeAll()
            
            for item in self.alertView?.hideArray ?? [] {
                item.isSelected = false
                self.alertView?.tableView.reloadData()
            }
            
            self.alertView?.onTypesCallBackResponse = self.onHideGhostModeTypesCallBack
            
            //cancel view
            self.alertView?.HandlehideViewBtn = {
                self.initGhostModeSwitchButton()
                DispatchQueue.main.async {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                }
            }
            
            self.alertView?.HandleSaveBtn = {
                self.initGhostModeSwitchButton()
                DispatchQueue.main.async {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                }
            }
            
            self.view.addSubview((self.alertView)!)
            
        default:
            break
        }
        
        print("\(switchCompassBarButton.isOn)")
    }
    
    @objc func handleGhostModeSwitchBtn() {
        
        if Defaults.ghostMode == false {
            self.alertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            DispatchQueue.main.async {
                self.switchGhostModeBarButton.isUserInteractionEnabled = false
                self.switchCompassBarButton.isUserInteractionEnabled = false
            }
            
            self.alertView?.parentVC = self
            
            self.alertView?.selectedHideType.removeAll()
            self.alertView?.typeIDs.removeAll()
            self.alertView?.typeStrings.removeAll()
            
            for item in self.alertView?.hideArray ?? [] {
                item.isSelected = false
                self.alertView?.tableView.reloadData()
            }
            
            self.alertView?.onTypesCallBackResponse = self.onHideGhostModeTypesCallBack
            
            //cancel view
            self.alertView?.HandlehideViewBtn = {
                self.initGhostModeSwitchButton()
                DispatchQueue.main.async {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                }
            }
            
            self.alertView?.HandleSaveBtn = {
                self.initGhostModeSwitchButton()
                DispatchQueue.main.async {
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                }
            }
            
            self.view.addSubview((self.alertView)!)
        }
        else {
            self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            self.showAlertView?.titleLbl.text = "Confirm?".localizedString
            self.showAlertView?.detailsLbl.text = "Are you sure you want to turn off private modes?".localizedString
            
            self.showAlertView?.HandleConfirmBtn = {
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.settingVM.toggleGhostMode(ghostMode: false, myAppearanceTypes: [0], completion: { error, data in
                        if let error = error {
                            DispatchQueue.main.async {
                                self.view.makeToast(error)
                            }
                            return
                        }
                        
                        guard data != nil else {return}
                        Defaults.ghostMode = false
                        Defaults.ghostModeEveryOne = false
                        Defaults.myAppearanceTypes = [0]
                        
                        DispatchQueue.main.async {
                            self.initGhostModeSwitchButton()
                        }
                        
                        DispatchQueue.main.async {
                            if self.isCompassOpen {
                                self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                            }else {
                                self.getAllFeeds(pageNumber: 0)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateSettings"), object: nil, userInfo: nil)
                        }
                    })
                }
                // handling code
                UIView.animate(withDuration: 0.3, animations: {
                    DispatchQueue.main.async {
                        self.switchGhostModeBarButton.isUserInteractionEnabled = true
                        self.switchCompassBarButton.isUserInteractionEnabled = true
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
                DispatchQueue.main.async {
                    self.initGhostModeSwitchButton()
                    self.switchGhostModeBarButton.isUserInteractionEnabled = true
                    self.switchCompassBarButton.isUserInteractionEnabled = true
                }
            }
            
            self.view.addSubview((self.showAlertView)!)
        }
    }
    
    func onHideGhostModeTypesCallBack(_ data: [String], _ value: [Int]) -> () {
        print(data)
        print(value)
        ghostModeToggle(ghostMode: true, myAppearanceTypes:value)
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
                }else {
                    Defaults.ghostModeEveryOne = false
                    Defaults.ghostMode = false
                }
            }
            
            DispatchQueue.main.async {
                self.initGhostModeSwitchButton()
                self.switchGhostModeBarButton.isUserInteractionEnabled = true
                self.switchCompassBarButton.isUserInteractionEnabled = true
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("updateSettings"), object: nil, userInfo: nil)
            }
            
            DispatchQueue.main.async {
                if self.isCompassOpen {
                    self.filterFeedsBy(degree: self.compassDegree, pageNumber: 0)
                }else {
                    self.getAllFeeds(pageNumber: 0)
                }
            }
        }
    }
    
}
