//
//  MapVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/08/2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import ObjectMapper
import MapKit
import GoogleMobileAds
import ListPlaceholder
import Network
import SDWebImage

https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere

let googleApiKey = "AIzaSyCF-EzIxAjm7tkolhph80-EAJmsCl0oemY"

//select location protocol
protocol PickingLocationFromTheMap {
    func selectLocation(With placeMark:CLPlacemark,location:CLLocationCoordinate2D)
}

//Singleton
class MapAppType {
    static var type: Bool = false
}

class IsMoreEventAtMarker {
    static var more: Bool = false
}

class LocationZooming {
    static var locationLat: Double = 0.0
    static var locationLng: Double = 0.0
    //    static var didSelected: Double = 0.0
}

public func delay(_ delay: Double, closure: @escaping () -> Void) {
    let deadline = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(
        deadline: deadline,
        execute: closure
    )
}

extension MapVC: HorizontalPaginationManagerDelegate {
    
    private func setupPagination() {
        self.paginationManager.refreshViewColor = .clear
        self.paginationManager.loaderColor = .white
    }
    
    private func fetchItems() {
        self.paginationManager.initialLoad()
    }
    
    func refreshAll(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.currentPage = 1
            self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
            self.collectionView.reloadData()
            completion(true)
        }
    }
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoadingList = true
            if self.currentPage < self.viewmodel.eventsOnlyMe.value?.totalPages ?? 0 {
                print("self.currentPage >> \(self.currentPage)")
                self.loadMoreItemsForList()
            }
            completion(true)
        }
    }
}


//create location
class EventsLocation {
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var typelocation:String = ""
    var markerIcon:String = ""
    var eventsCount:Int = 0
    var markerId:String = ""
    var isEvent:Bool = false
    var peopleCount:Int = 0
    var eventType:String = ""
    var eventList:[EventObj]? = nil
    
    init(location:CLLocationCoordinate2D,markerIcon:String,typelocation:String,eventsCount:Int,markerId:String,isEvent:Bool,peopleCount:Int,eventType:String,eventList:[EventObj]?) {
        self.location = location
        self.markerIcon = markerIcon
        self.typelocation = typelocation
        self.eventsCount = eventsCount
        self.markerId = markerId
        self.isEvent = isEvent
        self.peopleCount = peopleCount
        self.eventType = eventType
        self.eventList = eventList
    }
}

class MapVC: UIViewController ,UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var lastNextBtn: UIButton!
    @IBOutlet weak var showAddEventExplainedView: UIView!
    @IBOutlet weak var showFilterExplainedView: UIView!
    @IBOutlet weak var showNearByEventsExplainedView: UIView!
    @IBOutlet weak var nearByEventsExplainedSubView: UIView!
    @IBOutlet weak var nearByEventsDialogueView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addEventBtn: UIButton!
    @IBOutlet weak var goAddEventBtn: UIButton!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var subViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var radiusMLbl: UILabel!
    @IBOutlet weak var radiusKMLbl: UILabel!
    @IBOutlet weak var zoomingStatisticsView: UIView!
    @IBOutlet weak var sataliteBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var currentLocationBtn: UIButton!
    @IBOutlet weak var markerImg: UIImageView!
    @IBOutlet var bannerView: UIView!
    @IBOutlet weak var upDownViewBtn: UIButton!
    @IBOutlet weak var arrowUpDownImg: UIImageView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var upDownBtn: UIButton!
    @IBOutlet weak var noeventNearbyLbl: UILabel!
    @IBOutlet weak var hideCollectionView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    //    @IBOutlet weak var dualogImg: UIImageView!
    @IBOutlet weak var nextToShowMapBtn: UIButton!
    @IBOutlet weak var catsSuperView: UIView!
    @IBOutlet weak var catsSubView: UIView!
    @IBOutlet weak var catsCollectionView: UICollectionView!
    @IBOutlet weak var catsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var fakeAddEventBtn: UIButton!
    
    @IBOutlet weak var addEventDialogueLbl: UILabel!
    @IBOutlet weak var filterDialogueLbl: UILabel!
    @IBOutlet weak var nearByEventsDialogueLbl: UILabel!
    
    
    
    //MARK: - Properties
    lazy var showAlertView = Bundle.main.loadNibNamed("MapAlertView", owner: self, options: nil)?.first as? MapAlertView
    
    var locations:[EventsLocation] = [EventsLocation]()
    var location: CLLocationCoordinate2D? = nil
    let locationManager = CLLocationManager()
    var delegate:PickingLocationFromTheMap! = nil
    var currentPlaceMark : CLPlacemark? = nil
    var selectVC:String = ""
    var locationName = ""
    var isEventAdmin :Bool = false
    var appendNewLocation:Bool = false
    var viewmodel:EventsAroundMeViewModel = EventsAroundMeViewModel()
    var settingVM:SettingsViewModel = SettingsViewModel()
    var genderbylocationVM: GenderbylocationViewModel = GenderbylocationViewModel()
    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    var locationsModel:EventsAroundMeDataModel = EventsAroundMeDataModel()
    var catsviewmodel:AllCategoriesViewModel = AllCategoriesViewModel()
    let catsCellId = "TagCollectionViewCell"
    
    var transparentView = UIView()
    var eventsTableView = UITableView()
    var eventCellID = "EventsInLocationTableViewCell"
    var nearbyEventCellId = "NearbyEventsCollectionViewCell"
    
    var tableView: UITableView!
    var tableDataSource: GMSAutocompleteTableDataSource!
    
    let screenSize = UIScreen.main.bounds.size
    var isViewUp:Bool = false
    var bannerView2: GADBannerView!
    
    var sliderEventList:[EventObj]? = nil
    
    var catIDs:[String] = [String]()
    var catSelectedNames:[String] = [String]()
    var catSelectedArr:[CategoryObj] = [CategoryObj]()
    
    var switchFilterButton: CustomSwitch = CustomSwitch()
    
    private var layout: UICollectionViewFlowLayout!
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var activityIndiator : UIActivityIndicatorView? = UIActivityIndicatorView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Map".localizedString
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapVC), name: Notification.Name("updateMapVC"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFilterBtn), name: Notification.Name("updateFilterBtn"), object: nil)
        self.setupPagination()
        self.fetchItems()
        
        isViewUp = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        //        mapView.clear()
        CancelRequest.currentTask = true
        
        collectionViewHeight.constant = 0
        self.hideCollectionView.isHidden = true
        self.noeventNearbyLbl.isHidden = true
        subViewHeight.constant = 50
        isViewUp = false
        self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
        
        if Defaults.availableVC != "MapVC" {
            currentPage = 1
            let contentOffset = CGPoint(x: 0, y: 0)
            self.collectionView.setContentOffset(contentOffset, animated: false)
        }
        
        catsSuperView.isHidden = true
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        catIDs = Defaults.catIDs
        for cat in Defaults.catIDs {
            for item in Defaults.catSelectedNames {
                catSelectedArr.append(CategoryObj(id: cat, name: item, isSelected: true))
            }
        }
        
        catSelectedNames = Defaults.catSelectedNames
        initFilterBarButton()
        
        
        appendNewLocation = false
        goAddEventBtn.isHidden = true
        addEventBtn.isHidden = false
        CancelRequest.currentTask = false
        isViewUp = false
        self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
        
        if Defaults.token != "" {
            initProfileBarButton(didTap: Defaults.isFirstOpenMap)
        }
        
        clearNavigationBar()
        
        DispatchQueue.main.async {
            if Defaults.token != "" {
                self.updateLocation()
            }
            
            if Defaults.availableVC != "MapVC" {
                self.locationsModel.peoplocationDataMV?.removeAll()
                self.locationsModel.eventlocationDataMV?.removeAll()
                self.locations.removeAll()
                self.mapView.clear()
                
                self.setupGoogleMap(zoom1: 8, zoom2: 14)
                self.checkLocationPermission()
            }
        }
        
        
        markerImg.isHidden = true
        
        if !Defaults.hideAds {
            setupAds()
        }else {
            bannerViewHeight.constant = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private lazy var paginationManager: HorizontalPaginationManager = {
        let manager = HorizontalPaginationManager(scrollView: self.collectionView)
        manager.delegate = self
        return manager
    }()
    
    private var isDragging: Bool {
        return self.collectionView.isDragging
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getEventsOnlyAroundMe(pageNumber: currentPage)
    }
    
    //MARK: - APIs
    func getEventsOnlyAroundMe(pageNumber:Int) {
        
        self.subView.isHidden = false
        self.upDownViewBtn.isHidden = false
        
        DispatchQueue.main.async {
            if self.isViewUp == true {
                self.hideCollectionView.isHidden = false
            }else {
                self.hideCollectionView.isHidden = true
            }
        }
        
        self.hideCollectionView.showLoader()
        viewmodel.getAllEventsOnlyAroundMe(ByCatIds: catIDs, pageNumber: pageNumber)
        viewmodel.eventsOnlyMe.bind { [unowned self] value in
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if Defaults.availableVC == "MapVC" {
                    DispatchQueue.main.async {
                        self.collectionView.dataSource = self
                        self.collectionView.delegate = self
                        self.collectionView.reloadData()
                    }
                    
                    DispatchQueue.main.async {
                        if self.isViewUp == true {
                            self.collectionViewHeight.constant = 140
                            self.subViewHeight.constant = 190
                            
                            if value.data?.count == 0 {
                                self.noeventNearbyLbl.isHidden = false
                                if self.switchFilterButton.isOn == true {
                                    self.noeventNearbyLbl.text = "No events as yet in your chosen categories. Adjust your settings or check back later."
                                }else {
                                    self.noeventNearbyLbl.text = "No events as yet."
                                }
                            }else {
                                self.noeventNearbyLbl.isHidden = true
                            }
                        }else {
                            self.collectionViewHeight.constant = 0
                            self.subViewHeight.constant = 50
                            self.noeventNearbyLbl.isHidden = true
                            self.hideCollectionView.isHidden = true
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.hideCollectionView.hideLoader()
                        self.hideCollectionView.isHidden = true
                        self.isLoadingList = false
                    }
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
    
    func bindToModel() {
        self.mapView.clear()
        
        viewmodel.getAllEventsAroundMe(ByCatIds: catIDs)
        viewmodel.locations.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                
                DispatchQueue.main.async {
                    if Defaults.availableVC == "MapVC" {
                        self.locationsModel = value
                    }
                }
                
                DispatchQueue.main.async {
                    if Defaults.availableVC == "MapVC" {
                        self.setupMarkers(model: value)
                    }
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
            
            NotificationCenter.default.post(name: Notification.Name("updatebadgeInbox"), object: nil, userInfo: nil)
        }
    }
    
    func getCats() {
        catsviewmodel.getAllCategories()
        catsviewmodel.cats.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self.catsCollectionView.dataSource = self
                self.catsCollectionView.delegate = self
                self.catsCollectionView.reloadData()
                self.layout = TagsLayout()
                
                DispatchQueue.main.async {
                    if Defaults.isIPhoneLessThan2500 {
                        if value.count < 15 {
                            self.catsCollectionViewHeight.constant = CGFloat(((((value.count) / 3)) * 50) + 50)
                        }
                        else {
                            self.catsCollectionViewHeight.constant = 280
                        }
                    }else {
                        if value.count < 22 {
                            self.catsCollectionViewHeight.constant = CGFloat(((((value.count) / 3)) * 50) + 50)
                        }
                        else {
                            self.catsCollectionViewHeight.constant = 420
                        }
                    }
                }
            }
        }
        
        // Set View Model Event Listener
        catsviewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.view.makeToast(error)
                }
            }
        }
    }
    
    //MARK: - Helpers
    func updateUserInterface() {
        appDelegate.networkReachability()
        
        switch Network.reachability.status {
        case .unreachable:
            DispatchQueue.main.async {
                self.mapView.clear()
                NetworkConected.internetConect = false
                self.collectionViewHeight.constant = 0
                self.subView.isHidden = false
                self.upDownViewBtn.isHidden = true
                self.zoomingStatisticsView.isHidden = true
                self.HandleInternetConnection()
                self.noeventNearbyLbl.isHidden = true
                self.hideCollectionView.isHidden = true
            }
        case .wwan:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.zoomingStatisticsView.isHidden = false
                
                if Defaults.allowMyLocationSettings == true {
                    
                    DispatchQueue.main.async {
                        self.bindToModel()
                    }
                    if Defaults.token != "" {
                        self.updateMyLocation()
                    }
                    
                    DispatchQueue.main.async {
                        self.getCats()
                    }
                }
            }
        case .wifi:
            DispatchQueue.main.async {
                NetworkConected.internetConect = true
                self.zoomingStatisticsView.isHidden = false
                
                if Defaults.allowMyLocationSettings == true {
                    
                    DispatchQueue.main.async {
                        self.bindToModel()
                    }
                    
                    if Defaults.token != "" {
                        self.updateMyLocation()
                    }
                    
                    DispatchQueue.main.async {
                        self.getCats()
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
    
    func setupAds() {
        bannerView2 = GADBannerView(adSize: GADAdSizeBanner)
        bannerView2.adUnitID = URLs.adUnitBanner
        bannerView2.rootViewController = self
        bannerView2.load(GADRequest())
        bannerView2.delegate = self
        bannerView2.translatesAutoresizingMaskIntoConstraints = false
        bannerView.addSubview(bannerView2)
    }
    
    @objc func updateMapVC() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if Defaults.allowMyLocationSettings == true {
                self.updateUserInterface()
            }
        }
    }
    
    @objc func updateFilterBtn() {
        switchFilterButton.isUserInteractionEnabled = true
        initFilterBarButton()
    }
    
    func HandleInternetConnection() {
        markerImg.isHidden = true
        self.view.makeToast("Network is unavailable, please try again!".localizedString)
    }
    
    @objc func handleSubViewHide() {
        print("handleSubViewHide")
        
        subView.isHidden = false
        upDownViewBtn.isHidden = false
        isViewUp = false
        self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
        collectionViewHeight.constant = 0
        self.noeventNearbyLbl.isHidden = true
        self.hideCollectionView.isHidden = true
        subViewHeight.constant = 50
    }
    
    
    // locations markers
    func setupMarkers(model:EventsAroundList) {
        
        locations.removeAll()
        mapView.clear()
        
        var iconMarker = ""
        for item in model.eventlocationDataMV ?? [] {
            
            if item.event_Type == "Private" {
                iconMarker = "markerPrivateEvent_ic"
            }else if item.event_Type == "External" {
                iconMarker = "external_event_ic"
            }else if item.event_Type == "adminExternal" {
                iconMarker = "external_event_ic"
            }else {
                iconMarker = "eventMarker_ic"
            }
            
            locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), markerIcon: iconMarker, typelocation: "event", eventsCount: item.eventData?.count ?? 0, markerId: (item.eventData?.count ?? 0) == 1 ? item.eventData?[0].id ?? "" : "",isEvent: true,peopleCount: 0, eventType: item.event_Type, eventList: item.eventData))
        }
        
        DispatchQueue.main.async {
            for item in model.peoplocationDataMV ?? [] {
                self.locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), markerIcon: "markerLocations_ic", typelocation: "people", eventsCount: 1, markerId: "1",isEvent: false,peopleCount: item.totalUsers ?? 0, eventType: "", eventList: []))
            }
        }
        
        DispatchQueue.main.async {
            for item in self.locations {
                self.setupMarkerz(for: item.location, markerIcon: item.markerIcon, typelocation: item.typelocation, markerID: item.markerId, eventsCount: item.eventsCount,isEvent: item.isEvent,peopleCount: item.peopleCount, eventTypee: item.eventType)
                print("item.eventType ?? \(item.eventType)")
            }
        }
    }
    
    //create markers for locations events
    func setupMarkerz(for position:CLLocationCoordinate2D , markerIcon:String?,typelocation:String,markerID:String,eventsCount:Int,isEvent: Bool,peopleCount: Int,eventTypee:String)  {
        
        if appendNewLocation {
            mapView.clear()
        }
        
        let marker = GMSMarker(position: position)
        
        marker.snippet = typelocation
        marker.title = markerID
        marker.opacity = Float(eventsCount)
        
        marker.accessibilityValue = eventTypee
        
        if typelocation == "event" {
            if LocationZooming.locationLat == position.latitude && LocationZooming.locationLng == position.longitude {
                marker.appearAnimation = .pop
            }else {
                marker.appearAnimation = .none
            }
        }
        
        var xview:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        
        if Defaults.isIPhoneLessThan2500 {
            xview = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        }
        
        let labl = UILabel()
        labl.frame = xview.frame
        xview.backgroundColor = .clear
        labl.text = "\(eventsCount)"
        labl.textColor = .black
        labl.textAlignment = .center
        labl.font = UIFont(name: "Montserrat-Medium", size: 10)
        let imag:UIImageView = UIImageView()
        imag.frame = xview.frame
        imag.image = UIImage(named: markerIcon ?? "")
        imag.contentMode = .scaleToFill
        
        xview.addSubview(imag)
        xview.addSubview(labl)
        
        
        labl.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = labl.centerXAnchor.constraint(equalTo: xview.centerXAnchor)
        let verticalConstraint = labl.centerYAnchor.constraint(equalTo: xview.centerYAnchor, constant: Defaults.isIPhoneLessThan2500 == true ? -2 : -5)
        let widthConstraint = labl.widthAnchor.constraint(equalToConstant: xview.bounds.width)
        let heightConstraint = labl.heightAnchor.constraint(equalToConstant: xview.bounds.height)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        
        
        var xview2:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        if Defaults.isIPhoneLessThan2500 {
            xview2 = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        }
        
        let imag2:UIImageView = UIImageView()
        imag2.frame = xview2.frame
        imag2.image = UIImage(named: markerIcon ?? "")
        imag2.contentMode = .scaleToFill
        
        xview2.addSubview(imag2)
        
        
        if isEvent && eventTypee != "Private" {
            marker.iconView = xview
        }else {
            marker.iconView = xview2
        }
        
        marker.map = mapView
    }
    
    func setupViews() {
        //setup search bar
        addEventBtn.cornerRadiusView(radius: 10)
        fakeAddEventBtn.cornerRadiusView(radius: 10)
        goAddEventBtn.cornerRadiusView(radius: 10)
        sataliteBtn.cornerRadiusView(radius: 10)
        currentLocationBtn.cornerRadiusView(radius: 10)
        topContainerView.cornerRadiusView(radius: 10)
        nextBtn.setBorder(color: UIColor.white.cgColor, width: 2)
        lastNextBtn.setBorder(color: UIColor.white.cgColor, width: 2)
        nextToShowMapBtn.setBorder(color: UIColor.white.cgColor, width: 2)
        nextBtn.cornerRadiusForHeight()
        lastNextBtn.cornerRadiusForHeight()
        nextToShowMapBtn.cornerRadiusForHeight()
        bannerView.cornerRadiusView(radius: 8)
        nearByEventsDialogueView.cornerRadiusView(radius: 8)
        nearByEventsExplainedSubView.setCornerforTop()
        
        profileImg.isHidden = true
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clear
        searchBar.barTintColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.tintColor = .black
        searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        searchBar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        
        //setup search tableView
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        tableView = UITableView(frame: CGRect(x: 0, y:(self.screenSize.height) - (self.screenSize.height - 110), width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        tableView.isHidden = true
        view.addSubview(tableView)
        
        //setup events tableView
        eventsTableView.register(UINib(nibName: eventCellID, bundle: nil), forCellReuseIdentifier: eventCellID)
        eventsTableView.isScrollEnabled = true
        eventsTableView.separatorStyle = .none
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        collectionView.register(UINib(nibName: nearbyEventCellId, bundle: nil), forCellWithReuseIdentifier: nearbyEventCellId)
        catsCollectionView.register(UINib(nibName: catsCellId, bundle: nil), forCellWithReuseIdentifier: catsCellId)
        subView.setCornerforTop()
        
        zoomingStatisticsView.cornerRadiusView(radius: 6)
        catsSubView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        applyBtn.cornerRadiusView(radius: 8)
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 8)
        }
    }
    
    @objc func hideCatViews(_ sender: UITapGestureRecognizer? = nil) {
        catsSuperView.isHidden = true
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
    }
    
    func setupSwipeSubView() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubViewHide), name: Notification.Name("handleSubViewHide"), object: nil)
        if Defaults.allowMyLocationSettings {
            subView.addGestureRecognizer(createSwipeGestureRecognizer(for: .up))
            subView.addGestureRecognizer(createSwipeGestureRecognizer(for: .down))
            subView.addGestureRecognizer(createSwipeGestureRecognizer(for: .left))
            subView.addGestureRecognizer(createSwipeGestureRecognizer(for: .right))
            
            upDownViewBtn.addGestureRecognizer(createSwipeGestureRecognizer(for: .up))
            upDownViewBtn.addGestureRecognizer(createSwipeGestureRecognizer(for: .down))
            upDownViewBtn.addGestureRecognizer(createSwipeGestureRecognizer(for: .left))
            upDownViewBtn.addGestureRecognizer(createSwipeGestureRecognizer(for: .right))
        }else {
            removeGestureSwipeSubView()
        }
    }
    
    func removeGestureSwipeSubView() {
        subView.removeGestureRecognizer(createSwipeGestureRecognizer(for: .up))
        subView.removeGestureRecognizer(createSwipeGestureRecognizer(for: .down))
        subView.removeGestureRecognizer(createSwipeGestureRecognizer(for: .left))
        subView.removeGestureRecognizer(createSwipeGestureRecognizer(for: .right))
        upDownViewBtn.removeGestureRecognizer(createSwipeGestureRecognizer(for: .up))
        upDownViewBtn.removeGestureRecognizer(createSwipeGestureRecognizer(for: .down))
        upDownViewBtn.removeGestureRecognizer(createSwipeGestureRecognizer(for: .left))
        upDownViewBtn.removeGestureRecognizer(createSwipeGestureRecognizer(for: .right))
        
        if Defaults.allowMyLocationSettings {
            collectionViewHeight.constant = 140
            subViewHeight.constant = 190
            subView.isHidden = false
            isViewUp = true
            arrowUpDownImg.image = UIImage(named: "arrow-white-down_ic")
        }else {
            collectionViewHeight.constant = 0
            self.hideCollectionView.isHidden = true
            self.noeventNearbyLbl.isHidden = true
            subViewHeight.constant = 50
            subView.isHidden = false
            isViewUp = false
            arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
        }
    }
    
    //create marker for location selected
    func setupMarker(for position:CLLocationCoordinate2D)  {
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude,longitude: position.longitude,zoom: 15)
        
        if appendNewLocation {
            mapView.clear()
        }
        
        self.mapView.camera = camera
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "markerLocations_ic")
        marker.map = mapView
    }
    
    //update location manager
    private func updateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    //setup google map
    private func setupGoogleMap(zoom1:Float,zoom2:Float) {
        if Defaults.allowMyLocationSettings {
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = true
            self.mapView.isBuildingsEnabled = true
            self.mapView.isIndoorEnabled = true
            
            let lat = Double(Defaults.LocationLat) ?? 0.0
            let lng = Double(Defaults.LocationLng) ?? 0.0
            
            mapView.camera = GMSCameraPosition.camera(withLatitude: lat,longitude: lng, zoom: zoom1)
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            let city = GMSCameraPosition.camera(withLatitude: lat,longitude: lng, zoom: zoom2)
            self.mapView.animate(to: city)
            CATransaction.commit()
            
            LocationZooming.locationLat = lat
            LocationZooming.locationLng = lng
            
            Defaults.availableVC = "MapVC"
            print("availableVC >> \(Defaults.availableVC)")
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
    
    //create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel".localizedString, style: .cancel) { (UIAlertAction) in
            self.upDownBtn.isUserInteractionEnabled = false
            self.isViewUp = false
            self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            Defaults.allowMyLocationSettings = false
            self.removeGestureSwipeSubView()
            NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
        }
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings".localizedString, comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //create up & down view events in location taped
    func CreateSlideUpMenu() {
        let widow = UIApplication.shared.keyWindow
        
        transparentView.backgroundColor = .black.withAlphaComponent(0.8)
        transparentView.frame = self.view.frame
        widow?.addSubview(transparentView)
        
        eventsTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height/2.05)
        eventsTableView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 40)
        
        widow?.addSubview(eventsTableView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        transparentView.addGestureRecognizer(tap)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.5
            self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height - self.screenSize.height/2.05, width: self.screenSize.width, height: self.screenSize.height/2.05)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.0
            self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height/2.05)
            
            self.sliderEventList?.removeAll()
        }
    }
    
    //MARK: - Actions
    @IBAction func applyBtn(_ sender: Any) {
        if Defaults.token != "" {
            print("catIDs = \(catIDs) \\ \(Defaults.catIDs)")
            
            Defaults.catIDs = catIDs
            Defaults.catSelectedNames = catSelectedNames
            
            NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
            
            DispatchQueue.main.async {
                DispatchQueue.main.async {
                    self.locationsModel.peoplocationDataMV?.removeAll()
                    self.locationsModel.eventlocationDataMV?.removeAll()
                    self.locations.removeAll()
                    self.mapView.clear()
                }
                
                DispatchQueue.main.async {
                    if Defaults.token != "" {
                        self.updateLocation()
                    }
                    self.setupGoogleMap(zoom1: 8, zoom2: 14)
                }
                
                DispatchQueue.main.async {
                    self.collectionViewHeight.constant = 0
                    self.noeventNearbyLbl.isHidden = true
                    self.subViewHeight.constant = 50
                    self.subView.isHidden = false
                    self.isViewUp = false
                    self.hideCollectionView.isHidden = true
                    self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                }
                
                DispatchQueue.main.async {
                    self.checkLocationPermission()
                }
                
                DispatchQueue.main.async {
                    self.currentPage = 1
                    self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
            
            catsSuperView.isHidden = true
        }
        else {
            Router().toOptionsSignUpVC(IsLogout: false)
        }
    }
    
    @IBAction func hideCatsSuperView(_ sender: Any) {
        catsSuperView.isHidden = true
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        Defaults.isFirstOpenMap = true
        
        switchFilterButton.isUserInteractionEnabled = true
        
        showAddEventExplainedView.isHidden = true
        showFilterExplainedView.isHidden = true
        showNearByEventsExplainedView.isHidden = true
        
        if Defaults.token != "" {
            initProfileBarButton(didTap: true)
        }
    }
    
    @IBAction func nextToShowMapBtn(_ sender: Any) {
        showAddEventExplainedView.isHidden = true
        showFilterExplainedView.isHidden = true
        showNearByEventsExplainedView.isHidden = false
    }
    
    @IBAction func lastNextBtn(_ sender: Any) {
        showAddEventExplainedView.isHidden = false
        showFilterExplainedView.isHidden = true
        showNearByEventsExplainedView.isHidden = true
    }
    
    
    @IBAction func addEventBtn(_ sender: Any) {
        if Defaults.token != "" {
            checkLocationPermissionBtns()
            if NetworkConected.internetConect {
                if Defaults.allowMyLocationSettings == true {
                    self.appendNewLocation = true
                    self.view.makeToast("Please pick event's location".localizedString)
                    self.goAddEventBtn.isHidden = false
                    self.addEventBtn.isHidden = true
                    markerImg.isHidden = false
                }else {
                    markerImg.isHidden = true
                    self.checkLocationPermission()
                }
            }
        }else {
            Router().toOptionsSignUpVC(IsLogout: true)
        }
    }
    
    @IBAction func goAddEventBtn(_ sender: Any) {
        checkLocationPermissionBtns()
        if Defaults.allowMyLocationSettings {
            if self.appendNewLocation {
                
                DispatchQueue.main.async {
                    LocationZooming.locationLat = self.location?.latitude ?? 0.0
                    LocationZooming.locationLng = self.location?.longitude ?? 0.0
                }
                
                DispatchQueue.main.async {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AddEventVC") as? AddEventVC else {return}
                    vc.locationLat = self.location!.latitude
                    vc.locationLng = self.location!.longitude
                    self.addEventBtn.isHidden = false
                    self.goAddEventBtn.isHidden = true
                    self.markerImg.isHidden = true
                    vc.inMap = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        //        guard let vc = UIViewController.viewController(withStoryboard: .Profile, AndContollerID: "MyProfileViewController") as? MyProfileViewController else {return}
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func convertMapStyleBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            checkLocationPermissionBtns()
            if Defaults.allowMyLocationSettings {
                MapAppType.type = !MapAppType.type
                
                if MapAppType.type == true {
                    mapView.mapType = .satellite
                }else {
                    mapView.mapType = .normal
                }
            }
        }else {
            HandleInternetConnection()
        }
    }
    
    @IBAction func currentLocationBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            self.checkLocationPermissionBtns()
            
            if Defaults.allowMyLocationSettings {
                setupGoogleMap(zoom1: 14, zoom2: 18)
            }else {
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
            }
        }else {
            HandleInternetConnection()
        }
        
        searchBar.text = ""
    }
    
    
    @IBAction func upDownBtn(_ sender: Any) {
        if NetworkConected.internetConect {
            isViewUp.toggle()
            
            if Defaults.allowMyLocationSettings {
                if isViewUp {
                    print("Up")
                    collectionViewHeight.constant = 140
                    subViewHeight.constant = 190
                    subView.isHidden = false
                    isViewUp = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-down_ic")
                    
                    DispatchQueue.main.async {
                        //                        self.currentPage = 1
                        self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
                    }
                }else {
                    print("Down")
                    collectionViewHeight.constant = 0
                    self.hideCollectionView.isHidden = true
                    self.noeventNearbyLbl.isHidden = true
                    subViewHeight.constant = 50
                    subView.isHidden = false
                    isViewUp = false
                    arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                }
            }
            else {
                print("Down")
                collectionViewHeight.constant = 0
                self.hideCollectionView.isHidden = true
                self.noeventNearbyLbl.isHidden = true
                subViewHeight.constant = 50
                subView.isHidden = false
                isViewUp = false
                arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
            }
            
        }
        else {
            HandleInternetConnection()
        }
    }
    
    func angleFromCoordinate(firstCoordinate: CLLocationCoordinate2D,secondCoordinate: CLLocationCoordinate2D) -> Double {
        
        let deltaLongitude: Double = secondCoordinate.longitude - firstCoordinate.longitude
        let deltaLatitude: Double = secondCoordinate.latitude - firstCoordinate.latitude
        let angle = (Double.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
        
        if (deltaLongitude > 0) {
            return angle
        } else if (deltaLongitude < 0) {
            return angle + Double.pi
        } else if (deltaLatitude < 0) {
            return Double.pi
        } else {
            return 0.0
        }
    }
}

//MARK: - GMSMap View Delegate
extension MapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        self.location = coordinate
        let camera = GMSCameraPosition.camera(withLatitude: (location?.latitude)!, longitude: (location?.longitude)!, zoom: 16.0)
        mapView.animate(to: camera)
        
        if self.appendNewLocation {
            geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
                guard let error = error else {
                    self.locationName = (PM?.name)!
                    self.currentPlaceMark = PM!
                    print(self.locationName)
                    print("\(self.location!.latitude) : \(self.location!.longitude)")
                    self.view.makeToast((PM?.name)!)
                    return
                }
                
                self.showAlert(withMessage: error.localizedDescription)
            }
        }else {
            return
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if NetworkConected.internetConect {
            var pos: CLLocationCoordinate2D? = nil
            pos = marker.position
            print("locationEvent: \(pos?.latitude ?? 0.0),\(pos?.longitude ?? 0.0)")
            
            if marker.snippet == "event" {
                if Defaults.token != "" {
                    //Events by location
                    if marker.title != "" {
                        if marker.accessibilityValue == "External" {
                            DispatchQueue.main.async {
                                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                                vc.eventId = marker.title!
                                vc.inMap = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                                vc.eventId = marker.title!
                                vc.inMap = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }else {
                        for itm in self.locations {
                            if ((pos?.latitude ?? 0.0 ) == itm.location.latitude) && ((pos?.longitude ?? 0.0) == itm.location.longitude) {
                                sliderEventList = itm.eventList
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.eventsTableView.delegate = self
                            self.eventsTableView.dataSource = self
                            self.eventsTableView.reloadData()
                        }
                        
                        CreateSlideUpMenu()
                    }
                }
                else {
                    Router().toOptionsSignUpVC(IsLogout: false)
                }
            }else if marker.snippet == "NewEvent" {
                print("NEW EVENT")
            }else {
                //                if let controller = UIViewController.viewController(withStoryboard: .Map, AndContollerID: "GenderDistributionNC") as? UINavigationController, let vc = controller.viewControllers.first as? GenderDistributionVC {
                //                    vc.lat = pos?.latitude ?? 0.0
                //                    vc.lng = pos?.longitude ?? 0.0
                //                    self.present(controller, animated: true)
                //                }
            }
        }
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if self.appendNewLocation == true {
            let lat = mapView.camera.target.latitude
            let lng = mapView.camera.target.longitude
            location = CLLocationCoordinate2DMake(lat, lng)
            
            print("Center Location is === \(location!)")
        }
        
        // Find the coordinates
        let visibleRegion = mapView.projection.visibleRegion()
        let farLeftLocation = CLLocation(latitude: visibleRegion.farLeft.latitude, longitude: visibleRegion.farLeft.longitude)
        let centerLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        
        // Calculate the distance as radius.
        // The distance result from CLLocation is in meters, so we divide it by 1000 to get the value in kilometers
        let radiusKM = (centerLocation.distance(from: farLeftLocation) / 1000.0).rounded(toPlaces: 1)
        // Do something with the radius...
        print("radiusKM \(radiusKM)")
        radiusMLbl.text = "\(radiusKM * 1000) m"
        radiusKMLbl.text = "\(radiusKM) km"
    }
}

//MARK: - CLLocation manager delegate
extension MapVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if NetworkConected.internetConect {
            self.location = manager.location?.coordinate
            locationManager.stopUpdatingLocation()
            
            if Defaults.availableVC != "MapVC" {
                self.setupGoogleMap(zoom1: 8, zoom2: 14)
            }
            
            
        }else {
            print("NOT NETWORK AVILABLE")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            //check  location permissions
            //            self.checkLocationPermission()
        }
    }
    
    func checkLocationPermission() {
        
        if !Defaults.isFirstOpenMap {
            if Defaults.token != "" {
                nearByEventsDialogueLbl.text = "You can browse a list of events nearest to you here."
                filterDialogueLbl.text = "Click to set and display events from your preferred interest categories."
                addEventDialogueLbl.text = "To create an event, click on “+” to select a location on the map for your event then click “+” again to confirm location."
            }else {
                nearByEventsDialogueLbl.text = "You can browse a list of events nearest to you here."
                filterDialogueLbl.text = "You can sort filter events by your interests here."
                addEventDialogueLbl.text = "You can add your own event to the map here – inviting your connections or opening to all Friendzrs."
            }
            
            showFilterExplainedView.isHidden = false
            switchFilterButton.isUserInteractionEnabled = false
            addEventBtn.isUserInteractionEnabled = false
            sataliteBtn.isUserInteractionEnabled = false
            currentLocationBtn.isUserInteractionEnabled = false
            goAddEventBtn.isUserInteractionEnabled = false
        }else {
            showFilterExplainedView.isHidden = true
            switchFilterButton.isUserInteractionEnabled = true
            addEventBtn.isUserInteractionEnabled = true
            sataliteBtn.isUserInteractionEnabled = true
            currentLocationBtn.isUserInteractionEnabled = true
            goAddEventBtn.isUserInteractionEnabled = true
        }
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                self.upDownBtn.isUserInteractionEnabled = false
                self.isViewUp = false
                self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                Defaults.allowMyLocationSettings = false
                self.removeGestureSwipeSubView()
                NotificationCenter.default.post(name: Notification.Name("updateMapVC"), object: nil, userInfo: nil)
                locationManager.stopUpdatingLocation()
                self.zoomingStatisticsView.isHidden = true
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                Defaults.allowMyLocationSettings = true
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.updateUserInterface()
                }
                
                locationManager.showsBackgroundLocationIndicator = false
                locationManager.stopUpdatingLocation()
                
                DispatchQueue.main.async {
                    self.isViewUp = false
                    self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                    self.upDownBtn.isUserInteractionEnabled = true
                    self.setupSwipeSubView()
                    self.zoomingStatisticsView.isHidden = false
                }
            default:
                break
            }
        }
        else {
            print("Location services are not enabled")
            self.upDownBtn.isUserInteractionEnabled = false
            self.isViewUp = false
            self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            Defaults.allowMyLocationSettings = false
            self.removeGestureSwipeSubView()
            self.zoomingStatisticsView.isHidden = true
        }
        
    }
    
    func checkLocationPermissionBtns() {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                //open setting app when location services are disabled
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                Defaults.allowMyLocationSettings = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.showsBackgroundLocationIndicator = false
                Defaults.allowMyLocationSettings = true
            default:
                break
            }
        }
        else {
            print("Location in not allow")
            Defaults.allowMyLocationSettings = false
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
}

//MARK: - search in google map tableView dataSource and delegate
extension MapVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Update the GMSAutocompleteTableDataSource with the search text.
        if searchText != "" {
            tableView.isHidden = false
            tableDataSource.sourceTextHasChanged(searchText)
        } else {
            tableView.isHidden = true
        }
    }
}

extension MapVC: GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator off.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        // Reload table data
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        // Turn the network activity indicator on.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // Reload table data.
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        // Do something with the selected place.
        self.locationManager.stopUpdatingLocation()
        tableView.isHidden = true
        
        //        setupMarker(for: CLLocationCoordinate2D.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
        self.locationName = (place.name)!
        print(self.locationName)
        print("\(self.location!.latitude) : \(self.location!.longitude)")
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 17.0)
        self.mapView.animate(to: camera)
        self.searchBar.text = place.name
        
        geocode(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude) { (PM, error) in
            
            guard let error = error else {
                self.currentPlaceMark = PM!
                let place = self.currentPlaceMark?.addressDictionary
                
                if let city = place?["locality"] as? String {
                    print(city)
                } else {
                    print("\(self.currentPlaceMark?.locality ?? "")")
                }
                
                if let street = place?["thoroughfare"] as? String {
                    print(street)
                } else {
                    print("\(self.currentPlaceMark?.thoroughfare ?? "")")
                    
                }
                
                return
            }
            
            print("\(self.location!.latitude)","\(self.location!.longitude)")
            
            self.showAlert(withMessage: error.localizedDescription)
        }
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        // Handle the error.
        print("Error: \(error.localizedDescription)")
        self.showAlert(withMessage: error.localizedDescription)
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
}

//MARK: - events tableView dataSource and delegate
extension MapVC:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sliderEventList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = eventsTableView.dequeueReusableCell(withIdentifier: eventCellID, for: indexPath) as? EventsInLocationTableViewCell else {return UITableViewCell()}
        let model = sliderEventList?[indexPath.row]
        cell.eventTitleLbl.text = model?.title
        cell.eventDateLbl.text = model?.eventdate
        cell.joinedLbl.text = "Attendees : \(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
        
        cell.eventImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        
        cell.directionBtn.isHidden = true
        
        cell.HandleDirectionBtn = {
            let lat = Double("\(model?.lat ?? "")")
            let lng = Double("\(model?.lang ?? "")")
            
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

extension MapVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if NetworkConected.internetConect {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
                self.transparentView.alpha = 0.0
                self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height/2.05)
            }
            
            let model = sliderEventList?[indexPath.row]
            if Defaults.token != "" {
                if model?.eventtype == "External" {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                    vc.eventId = model?.id ?? ""
                    if model?.key == 1 {
                        vc.isEventAdmin = true
                    }else {
                        vc.isEventAdmin = false
                    }
                    
                    vc.inMap = true
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else {
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                    vc.eventId = model?.id ?? ""
                    if model?.key == 1 {
                        vc.isEventAdmin = true
                    }else {
                        vc.isEventAdmin = false
                    }
                    vc.inMap = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else {
                Router().toOptionsSignUpVC(IsLogout: false)
            }
        }
    }
}

//MARK: - events nearby collection view data source and delegate
extension MapVC:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == catsCollectionView {
            return catsviewmodel.cats.value?.count ?? 0
        }else {
            return viewmodel.eventsOnlyMe.value?.data?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == catsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: catsCellId, for: indexPath) as? TagCollectionViewCell else {return UICollectionViewCell()}
            let model = catsviewmodel.cats.value?[indexPath.row]
            cell.tagNameLbl.text = model?.name ?? ""
            cell.editBtn.isHidden = true
            cell.editBtnWidth.constant = 0
            
            if catIDs.contains(model?.id ?? "") {
                cell.containerView.backgroundColor = UIColor.FriendzrColors.primary
            }
            else {
                cell.containerView.backgroundColor = .black
            }
            
            cell.layoutSubviews()
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nearbyEventCellId, for: indexPath) as? NearbyEventsCollectionViewCell else {return UICollectionViewCell()}
            let model = viewmodel.eventsOnlyMe.value?.data?[indexPath.row]
            
            cell.eventTitleLbl.text = model?.title
            cell.eventDateLbl.text = model?.eventdate
            cell.joinedLbl.text = "Attendees : ".localizedString + "\(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
            
            cell.eventImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
            
            //            if model?.eventtype == "External" {
            //                cell.eventColorView.backgroundColor = UIColor.color("#00284c")
            //            }else {
            //                cell.eventColorView.backgroundColor = UIColor.FriendzrColors.primary!
            //            }
            
            //        cell.detailsBtn.backgroundColor = UIColor.color((model?.color ?? ""))
            
            cell.detailsBtn.tintColor = UIColor.color((model?.eventtypecolor ?? ""))
            cell.expandLbl.textColor = UIColor.color((model?.eventtypecolor ?? ""))
            cell.eventDateLbl.textColor = UIColor.color((model?.eventtypecolor ?? ""))
            cell.eventColorView.backgroundColor = UIColor.color((model?.eventtypecolor ?? ""))
            
            cell.HandledetailsBtn = {
                if Defaults.token != "" {
                    if model?.eventtype == "External" {
                        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                        vc.eventId = model?.id ?? ""
                        
                        if model?.key == 1 {
                            vc.isEventAdmin = true
                        }else {
                            vc.isEventAdmin = false
                        }
                        vc.inMap = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                        vc.eventId = model?.id ?? ""
                        
                        if model?.key == 1 {
                            vc.isEventAdmin = true
                        }else {
                            vc.isEventAdmin = false
                        }
                        vc.inMap = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else {
                    Router().toOptionsSignUpVC(IsLogout: false)
                }
            }
            return cell
        }
    }
}

extension MapVC:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == catsCollectionView {
            let model = catsviewmodel.cats.value?[indexPath.row]
            let width = model?.name?.widthOfString(usingFont: UIFont(name: "Montserrat-Medium", size: 12)!)
            return CGSize(width: width! + 50, height: 45)
        }
        else {
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            return CGSize(width: width/2.1, height: height - 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != catsCollectionView {
            let model = viewmodel.eventsOnlyMe.value?.data
            for (index,item) in model!.enumerated() {
                let locitm = CLLocationCoordinate2DMake(item.lat?.toDouble() ?? 0.0, item.lang?.toDouble() ?? 0.0)
                if index == indexPath.row {
                    if LocationZooming.locationLat != locitm.latitude && LocationZooming.locationLng != locitm.longitude {
                        animationZoomingMap(zoomIN: 17, zoomOUT: 15, lat: locitm.latitude, lng: locitm.longitude)
                    }
                    else {
                        self.mapView.clear()
                        self.setupMarkers(model: self.locationsModel)
                    }
                }
            }
        }
        else {
            if NetworkConected.internetConect {
                print("You selected cell #\(indexPath.row)!")
                let strData = catsviewmodel.cats.value?[indexPath.row]
                
                if catIDs.contains(strData?.id ?? "") {
                    catIDs = catIDs.filter { $0 != strData?.id}
                    catSelectedNames = catSelectedNames.filter { $0 != strData?.name}
                }
                else {
                    catIDs.append(strData?.id ?? "")
                    catSelectedNames.append(strData?.name ?? "")
                }
                
                print(catIDs)
                collectionView.reloadData()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

extension MapVC {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        // Find the coordinates
        let visibleRegion = mapView.projection.visibleRegion()
        let farLeftLocation = CLLocation(latitude: visibleRegion.farLeft.latitude, longitude: visibleRegion.farLeft.longitude)
        let centerLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        
        // Calculate the distance as radius.
        // The distance result from CLLocation is in meters, so we divide it by 1000 to get the value in kilometers
        let radiusKM = (centerLocation.distance(from: farLeftLocation) / 1000.0).rounded(toPlaces: 1)
        // Do something with the radius...
        print("radiusKM \(radiusKM)")
        radiusMLbl.text = "\(radiusKM * 1000) m"
        radiusKMLbl.text = "\(radiusKM) km"
    }
    
    func delay(seconds: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            closure()
        }
    }
    func animationZoomingMap(zoomIN:Float,zoomOUT:Float,lat:Double,lng:Double) {
        //        delay(seconds: 0.5) { () -> () in
        //            let zoomOut = GMSCameraUpdate.zoom(to: zoomOUT)
        //            self.mapView.animate(with: zoomOut)
        //
        //            self.delay(seconds: 0.5, closure: { () -> () in
        //
        //                let updatePos = CLLocationCoordinate2DMake(lat,lng)
        //                let updateCam = GMSCameraUpdate.setTarget(updatePos)
        //                self.mapView.animate(with: updateCam)
        //
        //                self.delay(seconds: 0.5, closure: { () -> () in
        //                    let zoomIn = GMSCameraUpdate.zoom(to: zoomIN)
        //                    self.mapView.animate(with: zoomIn)
        //                })
        //            })
        //        }
        
        let point = mapView.projection.point(for: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        let camera = mapView.projection.coordinate(for: point)
        let position = GMSCameraUpdate.setTarget(camera)
        
        delay(seconds: 0.7) { () -> () in
            self.mapView.animate(with: position)
        }
        
        LocationZooming.locationLat = lat
        LocationZooming.locationLng = lng
        
        //        delay(seconds: 2.5) { () -> () in
        //            self.mapView.clear()
        //            self.setupMarkers()
        //        }
    }
}

extension MapVC {
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func onFilterByCatsCallBack(_ listIDs: [String],_ listNames: [String],_ selectCats:[CategoryObj]) -> () {
        
        catIDs = listIDs
        catSelectedNames = listNames
        catSelectedArr = selectCats
        
        DispatchQueue.main.async {
            Defaults.catSelectedNames = listNames
            Defaults.catIDs = listIDs
        }
        
        print("catIDs = \(catIDs)")
        
        
        NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
        
        DispatchQueue.main.async {
            
            DispatchQueue.main.async {
                self.locationsModel.peoplocationDataMV?.removeAll()
                self.locationsModel.eventlocationDataMV?.removeAll()
                self.locations.removeAll()
                self.mapView.clear()
            }
            
            DispatchQueue.main.async {
                if Defaults.token != "" {
                    self.updateLocation()
                }
                self.setupGoogleMap(zoom1: 8, zoom2: 14)
            }
            
            DispatchQueue.main.async {
                self.collectionViewHeight.constant = 0
                self.noeventNearbyLbl.isHidden = true
                self.subViewHeight.constant = 50
                self.subView.isHidden = false
                self.isViewUp = false
                self.hideCollectionView.isHidden = true
                self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            }
            
            DispatchQueue.main.async {
                self.checkLocationPermission()
            }
            
            DispatchQueue.main.async {
                //                self.currentPage = 1
                self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
            }
        }
    }
    
    func initFilterBarButton() {
        switchFilterButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        switchFilterButton.onTintColor = UIColor.FriendzrColors.primary!
        switchFilterButton.setBorder()
        switchFilterButton.offTintColor = UIColor.white
        switchFilterButton.cornerRadius = 0.5
        switchFilterButton.thumbCornerRadius = 0.5
        switchFilterButton.animationDuration = 0.25
        
        if Defaults.catIDs.count != 0 {
            switchFilterButton.isOn = true
            switchFilterButton.thumbImage = UIImage(named: "filterMap_on_ic")
        }else {
            switchFilterButton.isOn = false
            switchFilterButton.thumbImage = UIImage(named: "filterMap_on_ic")
        }
        
        
        switchFilterButton.addTarget(self, action:  #selector(handleFilterSwitchBtn), for: .touchUpInside)
        
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .up))
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .down))
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .left))
        switchFilterButton.addGestureRecognizer(createFilterSwipeGestureRecognizer(for: .right))
        let barButton = UIBarButtonItem(customView: switchFilterButton)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    
    @objc private func didFilterSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        switch sender.direction {
        case .up:
            break
        case .down:
            break
        case .left:
            handleFilterByCategorySwitchBtn()
        case .right:
            handleFilterByCategorySwitchBtn()
        default:
            break
        }
        
        print("\(switchFilterButton.isOn)")
    }
    
    @objc func handleFilterSwitchBtn() {
        if (catsviewmodel.cats.value?.count ?? 0) != 0 {
            handleFilterByCategorySwitchBtn()
        }
        else {
            initFilterBarButton()
            return
        }
    }
    
    func handleFilterByCategorySwitchBtn() {
        if NetworkConected.internetConect {
            if Defaults.catIDs.count == 0 {
                switchFilterButton.isUserInteractionEnabled = false
                self.catsSuperView.isHidden = false
            }
            else {
                self.showAlertView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                self.showAlertView?.editBtn.isHidden = false
                
                self.showAlertView?.titleLbl.text = "Confirm?".localizedString
                self.showAlertView?.detailsLbl.text = "Are you sure you want to turn off filters or change the settings?".localizedString
                
                DispatchQueue.main.async {
                    self.switchFilterButton.isUserInteractionEnabled = false
                }
                
                self.showAlertView?.HandleOffBtn = {
                    if NetworkConected.internetConect {
                        
                        self.catIDs.removeAll()
                        self.catSelectedNames.removeAll()
                        self.catSelectedArr.removeAll()
                        Defaults.catIDs.removeAll()
                        Defaults.catSelectedNames.removeAll()
                        
                        DispatchQueue.main.async {
                            DispatchQueue.main.async {
                                self.locationsModel.peoplocationDataMV?.removeAll()
                                self.locationsModel.eventlocationDataMV?.removeAll()
                                self.locations.removeAll()
                                self.mapView.clear()
                            }
                            
                            DispatchQueue.main.async {
                                if Defaults.token != "" {
                                    self.updateLocation()
                                }
                                
                                self.setupGoogleMap(zoom1: 8, zoom2: 14)
                            }
                            
                            DispatchQueue.main.async {
                                self.collectionViewHeight.constant = 0
                                self.noeventNearbyLbl.isHidden = true
                                self.subViewHeight.constant = 50
                                self.subView.isHidden = false
                                self.isViewUp = false
                                self.hideCollectionView.isHidden = true
                                self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                            }
                            
                            DispatchQueue.main.async {
                                self.checkLocationPermission()
                            }
                            
                            DispatchQueue.main.async {
                                //                                self.currentPage = 1
                                self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
                            }
                        }
                    }
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
                            self.switchFilterButton.isUserInteractionEnabled = true
                        }
                        
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.showAlertView?.HandleHideViewBtn = {
                    DispatchQueue.main.async {
                        self.initFilterBarButton()
                        self.switchFilterButton.isUserInteractionEnabled = true
                    }
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                }
                
                self.showAlertView?.HandleEditBtn = {
                    // handling code
                    UIView.animate(withDuration: 0.3, animations: {
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                        self.showAlertView?.alpha = 0
                    }) { (success: Bool) in
                        self.showAlertView?.removeFromSuperview()
                        self.showAlertView?.alpha = 1
                        self.showAlertView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }
                    
                    self.initFilterBarButton()
                    self.switchFilterButton.isUserInteractionEnabled = false
                    self.catsSuperView.isHidden = false
                    
                }
                
                self.view.addSubview((self.showAlertView)!)
            }
        }
        else {
            HandleInternetConnection()
            if Defaults.catIDs.count != 0 {
                switchFilterButton.isOn = true
            }else {
                switchFilterButton.isOn = false
            }
        }
    }
    
    private func createFilterSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didFilterSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
    
    //    func addBottomSheetView(scrollable: Bool? = true) {
    //        let bottomSheetVC = scrollable! ? ScrollableBottomSheetViewController() : BottomSheetViewController()
    //
    //        self.addChild(bottomSheetVC)
    //        self.view.addSubview(bottomSheetVC.view)
    //        bottomSheetVC.didMove(toParent: self)
    //
    //        let height = view.frame.height
    //        let width  = view.frame.width
    //        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    //    }
    
    // MARK: - Actions
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        let frame = subView.frame
        
        switch sender.direction {
        case .up:
            if NetworkConected.internetConect{
                print("Up")
                if Defaults.allowMyLocationSettings {
                    collectionViewHeight.constant = 140
                    subViewHeight.constant = 190
                    subView.isHidden = false
                    isViewUp = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-down_ic")
                    
                    DispatchQueue.main.async {
                        //                        self.currentPage = 1
                        self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
                    }
                }
                else {
                    collectionViewHeight.constant = 0
                    self.noeventNearbyLbl.isHidden = true
                    subViewHeight.constant = 50
                    subView.isHidden = false
                    isViewUp = false
                    self.hideCollectionView.isHidden = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                    
                    createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                }
            }else {
                HandleInternetConnection()
            }
        case .down:
            if NetworkConected.internetConect {
                print("Down")
                collectionViewHeight.constant = 0
                self.hideCollectionView.isHidden = true
                self.noeventNearbyLbl.isHidden = true
                subViewHeight.constant = 50
                subView.isHidden = false
                isViewUp = false
                arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
            }else {
                HandleInternetConnection()
            }
        case .left: break
        case .right: break
        default:
            break
        }
        
        UIView.animate(withDuration: 0.25) {
            self.subView.frame = frame
        }
        
        print("x:\(frame.origin.x),y:\(frame.origin.y)")
    }
    
    // MARK: - Helper Methods
    
    private func createSwipeGestureRecognizer(for direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        // Initialize Swipe Gesture Recognizer
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        // Configure Swipe Gesture Recognizer
        swipeGestureRecognizer.direction = direction
        
        return swipeGestureRecognizer
    }
}

extension MapVC:GADBannerViewDelegate {
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
