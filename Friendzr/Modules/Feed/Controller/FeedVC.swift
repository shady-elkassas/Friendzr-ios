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

let screenH: CGFloat = UIScreen.main.bounds.height
let screenW: CGFloat = UIScreen.main.bounds.width

class FeedVC: UIViewController {
    
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
    
    @IBOutlet weak var hideView: UIView!
    
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
    
    lazy var deleteAlertView = Bundle.main.loadNibNamed("BlockAlertView", owner: self, options: nil)?.first as? BlockAlertView
    
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
    
    let cellID = "FeedsTableViewCell"
    let emptyCellID = "EmptyViewTableViewCell"
    
    var viewmodel:FeedViewModel = FeedViewModel()
    var requestFriendVM:RequestFriendStatusViewModel = RequestFriendStatusViewModel()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    var settingVM:SettingsViewModel = SettingsViewModel()

    var refreshControl = UIRefreshControl()
    let switchBarButton = Switch()
    
    var btnsSelected:Bool = false
    var internetConnect:Bool = false
    
    var currentPage : Int = 0
    var isLoadingList : Bool = false

    var isSendRequest:Bool = false
    
    var locationLat = 0.0
    var locationLng = 0.0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Feed"
        setup()
        initSwitchBarButton()
        pullToRefresh()
        addCompassView()
        
        if Defaults.allowMyLocation == true {
            DispatchQueue.main.async {
                self.updateUserInterface()
            }
            self.allowLocView.isHidden = true
        }else {
            self.hideView.isHidden = true
            self.emptyView.isHidden = true
            self.allowLocView.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
        initProfileBarButton()
        filterDir = switchBarButton.isOn
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeeds), name: Notification.Name("updateFeeds"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addCompassView() {
        let child = UIHostingController(rootView: CompassViewSwiftUI())
        compassContanierView.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = child.view.centerXAnchor.constraint(equalTo: compassContanierView.centerXAnchor)
        let verticalConstraint = child.view.centerYAnchor.constraint(equalTo: compassContanierView.centerYAnchor)
        let widthConstraint = child.view.widthAnchor.constraint(equalToConstant: 200)
        let heightConstraint = child.view.heightAnchor.constraint(equalToConstant: 200)
        compassContanierView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    //MARK:- APIs
    @objc func updateFeeds() {
        if Defaults.allowMyLocation == true {
            DispatchQueue.main.async {
                self.updateUserInterface()
            }
            self.allowLocView.isHidden = true
        }else {
            self.hideView.isHidden = true
            self.emptyView.isHidden = true
            self.allowLocView.isHidden = false
        }
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getAllFeeds(pageNumber: currentPage)
    }
    
    func getAllFeeds(pageNumber:Int) {
        self.showLoading()
        hideView.isHidden = false
        viewmodel.getAllUsers(pageNumber: pageNumber)
        viewmodel.feeds.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.hideLoading()
                hideView.isHidden = true
                
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
//                self.showAlert(withMessage: error)
                print(error)
            }
        }
    }
        
    func filterFeedsBy(degree:Double,pageNumber:Int) {
        self.showLoading()
        viewmodel.filterFeeds(Bydegree: degree, pageNumber: pageNumber)
        viewmodel.feeds.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                tableView.delegate = self
                tableView.dataSource = self
                tableView.reloadData()
                
                self.isLoadingList = false
                self.tableView.tableFooterView = nil
                
                isSendRequest = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.hideLoading()
                })
            })
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
//                self.showAlert(withMessage: error)
                print(error)
            }
        }
    }
    
    func updateMyLocation() {
        updateLocationVM.updatelocation(ByLat: "\(Defaults.LocationLat)", AndLng: "\(Defaults.LocationLng)") { error, data in
            if let error = error {
                self.showAlert(withMessage: error)
                return
            }
            
            guard let data = data else {return}
            Defaults.LocationLat = data.lat
            Defaults.LocationLng = data.lang
        }
    }
    
    //MARK: - Helper
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            self.emptyView.isHidden = false
            self.hideView.isHidden = true
            if Defaults.allowMyLocation == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
            getAllFeeds(pageNumber: 0)
            
            if Defaults.allowMyLocation == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                self.updateMyLocation()
            }
        case .wifi:
            self.emptyView.isHidden = true
            if Defaults.allowMyLocation == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            internetConnect = true
            getAllFeeds(pageNumber: 0)
            
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
            internetConnect = false
            HandleInternetConnection()
        case .wwan:
            self.emptyView.isHidden = true
            internetConnect = true
        case .wifi:
            self.emptyView.isHidden = true
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
        if Defaults.allowMyLocation == true {
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
            if Defaults.allowMyLocation == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            self.view.makeToast("No avaliable newtwok ,Please try again!".localizedString)
        }else {
            emptyView.isHidden = false
            if Defaults.allowMyLocation == true {
                self.allowLocView.isHidden = true
            }else {
                self.allowLocView.isHidden = false
            }
            emptyImg.image = UIImage.init(named: "nointernet")
            emptyLbl.text = "No avaliable newtwok ,Please try again!".localizedString
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
        updateUserInterface()
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
    
    
    //MARK: - Actions
    @IBAction func nextBtn(_ sender: Any) {
        filterHideView.isHidden = true
        Defaults.isFirstFilter = true
        
        createLocationManager()
        filterDir = true
        filterBtn.isHidden = false
        compassContanierView.isHidden = false
        compassContainerViewHeight.constant = 320
//        compassContanierView.addSubview(dScaView)
    }
    
    
    @IBAction func tryAgainBtn(_ sender: Any) {
        updateUserInterface()
    }

    @IBAction func filterBtn(_ sender: Any) {
        filterFeedsBy(degree: compassDegree, pageNumber: 1)
    }
    
    @IBAction func allowLocationBtn(_ sender: Any) {
        
        self.deleteAlertView?.frame = CGRect(x: 0, y: -100, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.deleteAlertView?.titleLbl.text = "Confirm?".localizedString
        self.deleteAlertView?.detailsLbl.text = "Are you sure you want to turn on your location?"
        
        self.deleteAlertView?.HandleConfirmBtn = {
            self.updateNetworkForBtns()
            
            if self.internetConnect {
                self.settingVM.toggleAllowMyLocation(allowMyLocation: true) { error, data in
                    if let error = error {
                        self.showAlert(withMessage: error)
                        return
                    }
                    
                    guard let data = data else {
                        return
                    }
                    
                    Defaults.allowMyLocation = data.allowmylocation ?? false
                    
                    DispatchQueue.main.async {
                        self.updateUserInterface()
                    }
                    
                    self.updateMyLocation()
                }
            }
            // handling code
            UIView.animate(withDuration: 0.3, animations: {
                self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.deleteAlertView?.alpha = 0
            }) { (success: Bool) in
                self.deleteAlertView?.removeFromSuperview()
                self.deleteAlertView?.alpha = 1
                self.deleteAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }
        
        self.view.addSubview((self.deleteAlertView)!)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viewmodel.feeds.value?.data?.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? FeedsTableViewCell else {return UITableViewCell()}
            let model = viewmodel.feeds.value?.data?[indexPath.row]
            cell.friendRequestNameLbl.text = model?.userName
            cell.friendRequestUserNameLbl.text = "@\(model?.displayedUserName ?? "")"
            cell.friendRequestImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeholder"))
            
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
            
            cell.HandleSendRequestBtn = { //send request
                self.btnsSelected = true
                self.updateNetworkForBtns()
                if self.internetConnect {
                    self.showLoading()
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 1) { error, message in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let message = message else {return}
                        self.showAlert(withMessage: message)
                        
                        DispatchQueue.main.async {
                            self.getAllFeeds(pageNumber: 0)
                        }
                    }
                }else {
                    return
                }
            }
            
            cell.HandleAccseptBtn = { //respond request
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.showLoading()
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 2) { error, message in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let message = message else {return}
                        self.showAlert(withMessage: message)
                      
                        DispatchQueue.main.async {
                            self.getAllFeeds(pageNumber: 0)
                        }
                    }
                }else {
                    return
                }
            }
            
            cell.HandleRefusedBtn = { // refused request
                
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.showLoading()
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let message = message else {return}
                        self.showAlert(withMessage: message)
                        DispatchQueue.main.async {
                            self.getAllFeeds(pageNumber: 0)
                        }
                    }
                }else {
                    return
                }
            }
            
            cell.HandleMessageBtn = { //block account
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.self.internetConnect {
                    Router().toChatVC(isEvent: false, eventChatID: "", leavevent: 0, chatuserID: model?.userId ?? "", isFriend: true, titleChatImage: model?.image ?? "", titleChatName: model?.userName ?? "")
                }else {
                    return
                }
            }
            
            cell.HandleUnblocktBtn = { //unblock account
                self.btnsSelected = true
                self.updateNetworkForBtns()
                
                if self.internetConnect {
                    self.showLoading()
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 4) { error, message in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let message = message else {return}
                        self.showAlert(withMessage: message)
                        DispatchQueue.main.async {
                            self.getAllFeeds(pageNumber: 0)
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
                    self.showLoading()
                    self.requestFriendVM.requestFriendStatus(withID: model?.userId ?? "", AndKey: 6) { error, message in
                        self.hideLoading()
                        if let error = error {
                            self.showAlert(withMessage: error)
                            return
                        }
                        
                        guard let message = message else {return}
                        self.showAlert(withMessage: message)
                        DispatchQueue.main.async {
                            self.getAllFeeds(pageNumber: 0)
                        }
                    }
                }else {
                    return
                }
            }
            
            return cell

        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath) as? EmptyViewTableViewCell else {return UITableViewCell()}
            return cell
        }
    }
}

//extension Table View Delegate
extension FeedVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewmodel.feeds.value?.data?.count != 0 {
            return 80
        }else {
            return 350
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        btnsSelected = true
        updateNetworkForBtns()
        
        if internetConnect {
            if viewmodel.feeds.value?.data?.count != 0 {
                guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "FriendProfileVC") as? FriendProfileVC else {return}
                vc.userID = viewmodel.feeds.value?.data?[indexPath.row].userId ?? ""
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
                      self.view.makeToast("No more data here")
                  }
                  return
              }
          }
      }
}

extension FeedVC: CLLocationManagerDelegate {
    
    func initSwitchBarButton() {
//        switchBarButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        switchBarButton.onTintColor = UIColor.FriendzrColors.primary!
        switchBarButton.thumbTintColor = .white
        switchBarButton.addTarget(self, action: #selector(handleSwitchBtn), for: .touchUpInside)
        switchBarButton.thumbImage = UIImage(named: "compass_ic")?.cgImage
        let barButton = UIBarButtonItem(customView: switchBarButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    

    @objc func handleSwitchBtn() {
        print("\(switchBarButton.isOn)")

        // Azimuth
        if Defaults.allowMyLocation == true {
            if switchBarButton.isOn {
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
                    compassContainerViewHeight.constant = 320
//                    compassContanierView.addSubview(dScaView)
                    compassContanierView.setCornerforTop(withShadow: true, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 35)
                }
            }else {
                filterHideView.isHidden = true
                Defaults.isFirstFilter = true
                
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
                filterDir = false
                compassContanierView.isHidden = true
                
                
                filterBtn.isHidden = true
                compassContainerViewHeight.constant = 0
                
                if Defaults.allowMyLocation == true {
                    DispatchQueue.main.async {
                        self.updateUserInterface()
                    }
                    self.allowLocView.isHidden = true
                }else {
                    self.emptyView.isHidden = true
                    self.allowLocView.isHidden = false
                }
            }
        }else {
            switchBarButton.isOn = false
            self.showAlert(withMessage: "Please allow your location")
        }
    }

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
