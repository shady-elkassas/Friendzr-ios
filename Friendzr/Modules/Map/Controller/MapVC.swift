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
import AMShimmer

let googleApiKey = "AIzaSyCF-EzIxAjm7tkolhph80-EAJmsCl0oemY"

//Singletonw
class MapAppType {
    static var type: Bool = false
}

class LocationZooming {
    static var locationLat: Double = 0.0
    static var locationLng: Double = 0.0
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupPagination()
            self.currentPage = 1
            self.getEventsOnlyAroundMe(pageNumber: self.currentPage)
            self.collectionView.reloadData()
            completion(true)
        }
    }
    
    func loadMore(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupPagination()
            self.isLoadingList = true
            if self.currentPage < self.viewmodel.eventsOnlyMe.value?.totalPages ?? 0 {
                print("self.currentPage >> \(self.currentPage)")
                self.loadMoreItemsForList()
            }else {
                self.paginationManager.removeRightLoader()
            }
            
            completion(true)
        }
    }
}


//MARK: - Create location
class EventsLocation {
    var location:CLLocationCoordinate2D
    var typelocation:String
    var markerIcon:String
    var eventsCount:Int
    var markerId:String
    var isEvent:Bool
    var peopleCount:Int
    var eventType:String
    var eventList:[EventObj]?
    
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
    
    deinit {
        print("EventsLocation is not here now")
    }
}

class MapVC: UIViewController ,UIGestureRecognizerDelegate {
    
    //MARK: - Outlets
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
    
    @IBOutlet weak var eventsByLocationSuperView: UIView!
    @IBOutlet weak var dismissEventsByLocationSuperView: UIButton!
    @IBOutlet weak var eventsByLocationTableView: UITableView!
    @IBOutlet weak var eventsByLocationSubView: UIView!
    @IBOutlet weak var shimmerEventsByLocationView: UIView!
    
    
    
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var thisWeekBtn: UIButton!
    @IBOutlet weak var thisMonthBtn: UIButton!
    @IBOutlet weak var customBtn: UIButton!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var startDateTxt: UITextField!
    @IBOutlet weak var endDateTxt: UITextField!
    
    
    
    //MARK: - Properties
    lazy var showAlertView = Bundle.main.loadNibNamed("MapAlertView", owner: self, options: nil)?.first as? MapAlertView
    lazy var dateAlertView = Bundle.main.loadNibNamed("EventCalendarView", owner: self, options: nil)?.first as? EventCalendarView

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
//    var updateLocationVM:UpdateLocationViewModel = UpdateLocationViewModel()
    var locationsModel:EventsAroundMeDataModel = EventsAroundMeDataModel()
    var catsviewmodel:AllCategoriesViewModel = AllCategoriesViewModel()
    let catsCellId = "TagCollectionViewCell"
    
//    var transparentView = UIView()
//    var eventsTableView = UITableView()
    var eventCellID = "EventsInLocationTableViewCell"
    var nearbyEventCellId = "NearbyEventsCollectionViewCell"
    
    var tableView: UITableView!
    var tableDataSource: GMSAutocompleteTableDataSource!
    
    let screenSize = UIScreen.main.bounds.size
    var isViewUp:Bool = false
    var bannerView2: GADBannerView!
    
//    var sliderEventList:[EventObj]? = []
    
    var catIDs:[String] = [String]()
    var catSelectedNames:[String] = [String]()
    var catSelectedArr:[CategoryObj] = [CategoryObj]()
    
    var switchFilterButton: CustomSwitch = CustomSwitch()
    var iconMarker = ""
    
    private var layout: UICollectionViewFlowLayout!
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var activityIndiator : UIActivityIndicatorView? = UIActivityIndicatorView()
    
    var checkoutName:String = ""
    
    var pepoleLocations = [CLLocationCoordinate2D]()
    
    var dateTypeSelected = ""
    let datePicker1 = UIDatePicker()
    let datePicker2 = UIDatePicker()
    var startDate = ""
    var endDate = ""
    var minimumDate:Date = Date()
    var maximumDate:Date = Date()

    private lazy var paginationManager: HorizontalPaginationManager = {
        let manager = HorizontalPaginationManager(scrollView: self.collectionView)
        manager.delegate = self
        return manager
    }()
    
    private var isDragging: Bool {
        return self.collectionView.isDragging
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Events".localizedString
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapVC), name: Notification.Name("updateMapVC"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFilterBtn), name: Notification.Name("updateFilterBtn"), object: nil)
        
        self.setupPagination()
        self.fetchItems()
        isViewUp = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setCatIds()
        
        initFilterBarButton()
        
        //        checkDeepLinkDirection()
        
        CancelRequest.currentTask = false
        
        isViewUp = false
        
        self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
        
        if Defaults.token != "" {
            initProfileBarButton(didTap: Defaults.isFirstOpenMap)
        }
        
        clearNavigationBar(size: 16)
        
        DispatchQueue.main.async {
            self.updateLocation()
            
            if Defaults.availableVC != "MapVC" {
                self.locationsModel.peoplocationDataMV?.removeAll()
                self.locationsModel.eventlocationDataMV?.removeAll()
                self.locations.removeAll()
                self.mapView.clear()
                
                self.setupGoogleMap(zoom1: 8, zoom2: 14)
                self.checkLocationPermission()
            }
        }
        
        if Defaults.isSubscribe == false {
            setupAds()
        }else {
            bannerViewHeight.constant = 0
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
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
    
    
    //MARK: - APIs
    func getEventsOnlyAroundMe(pageNumber:Int) {
        let startDatee = Date()
        
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
        viewmodel.getAllEventsOnlyAroundMe(ByCatIds: catIDs, pageNumber: pageNumber, dateCriteria: dateTypeSelected, startDate: startDateTxt.text!, endDate: endDateTxt.text!)
        viewmodel.eventsOnlyMe.bind { [weak self] value in
            
            DispatchQueue.main.async {
                if Defaults.availableVC == "MapVC" {
                    DispatchQueue.main.async {
                        self?.collectionView.dataSource = self
                        self?.collectionView.delegate = self
                        self?.collectionView.reloadData()
                    }
                    
                    DispatchQueue.main.async {
                        self?.handleShowEventsSubView(value: value)
                    }
                    
                    DispatchQueue.main.async {
                        self?.hideCollectionView.hideLoader()
                        self?.hideCollectionView.isHidden = true
                        self?.isLoadingList = false
                    }
                    
                    let executionTimeWithSuccess41 = Date().timeIntervalSince(startDatee)
                    print("executionTimeWithSuccess41 \(executionTimeWithSuccess41) second")
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
    
    func bindToModel() {
        let startDatee = Date()
        
        viewmodel.getAllEventsAroundMe(ByCatIds: catIDs, dateCriteria: dateTypeSelected, startDate: startDateTxt.text!, endDate: endDateTxt.text!)
        let executionTimeWithSuccess40 = Date().timeIntervalSince(startDatee)
        print("executionTimeWithSuccess40 \(executionTimeWithSuccess40) second")
        
        viewmodel.locations.bind { [weak self] value in
            let executionTimeWithSuccess43 = Date().timeIntervalSince(startDatee)
            print("executionTimeWithSuccess43 \(executionTimeWithSuccess43) second")
            
            DispatchQueue.main.async {
                
                let executionTimeWithSuccess45 = Date().timeIntervalSince(startDatee)
                print("executionTimeWithSuccess45 \(executionTimeWithSuccess45) second")
                
                DispatchQueue.main.async {
                    if Defaults.availableVC == "MapVC" {
                        self?.locationsModel = value
                    }
                }
                
                DispatchQueue.main.async {
                    if Defaults.availableVC == "MapVC" {
                        self?.setupMarkers(model: value)
                    }
                }
                
                let executionTimeWithSuccess46 = Date().timeIntervalSince(startDatee)
                print("executionTimeWithSuccess46 \(executionTimeWithSuccess46) second")
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                if Defaults.availableVC == "MapVC" {
                    self?.view.makeToast(error)
                }
            }
        }
    }
    
    func getCats() {
        catsviewmodel.getAllCategories()
        catsviewmodel.cats.bind { [weak self] value in
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self?.catsCollectionView.dataSource = self
                self?.catsCollectionView.delegate = self
                self?.catsCollectionView.reloadData()
                self?.layout = TagsLayout()
                
                DispatchQueue.main.async {
                    if Defaults.isIPhoneLessThan2500 {
                        if value.count < 15 {
                            self?.catsCollectionViewHeight.constant = CGFloat(((((value.count) / 3)) * 50) + 50)
                        }
                        else {
                            self?.catsCollectionViewHeight.constant = 280
                        }
                    }else {
                        if value.count < 22 {
                            self?.catsCollectionViewHeight.constant = CGFloat(((((value.count) / 3)) * 50) + 50)
                        }
                        else {
                            self?.catsCollectionViewHeight.constant = 420
                        }
                    }
                }
            }
        }
        
        // Set View Model Event Listener
        catsviewmodel.error.bind { [weak self]error in
            DispatchQueue.main.async {
                self?.view.makeToast(error)
            }
        }
    }
    
    func loadMoreItemsForList(){
        currentPage += 1
        getEventsOnlyAroundMe(pageNumber: currentPage)
    }
    
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
                    
                    DispatchQueue.main.async {
                        self.getCats()
                    }
                    
                    
                    self.checkDeepLinkDirection()
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
                    
                    DispatchQueue.main.async {
                        self.getCats()
                    }
                    
                    
                    self.checkDeepLinkDirection()
                }
            }
        }
        
        print("Reachability Summary")
        print("Status:", Network.reachability.status)
        print("HostName:", Network.reachability.hostname ?? "nil")
        print("Reachable:", Network.reachability.isReachable)
        print("Wifi:", Network.reachability.isReachableViaWiFi)
    }
    
    //MARK: - Helpers
    
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
        
        //        pepoleLocations.removeAll()
        //        self.generateLocs()
        
        for item in model.eventlocationDataMV ?? [] {
            
            if item.eventTypeName == "Private" {
                iconMarker = "markerPrivateEvent_ic"
            }else if item.eventTypeName == "External" {
                iconMarker = "external_event_ic"
            }else if item.eventTypeName == "adminExternal" {
                iconMarker = "external_event_ic"
            }else if item.eventTypeName == "Whitelabel" {
                iconMarker = item.eventMarkerImage ?? ""
            }
            else {
                iconMarker = "eventMarker_ic"
            }
            
            locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), markerIcon: iconMarker, typelocation: "event", eventsCount: item.count ?? 0, markerId: (item.count ?? 0) == 1 ? item.eventId ?? "" : "",isEvent: true,peopleCount: 0, eventType: item.eventTypeName, eventList: []))
        }
        
        DispatchQueue.main.async {
            for item in model.peoplocationDataMV ?? [] {
                self.locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), markerIcon: "markerLocations_ic", typelocation: "people", eventsCount: 1, markerId: "1",isEvent: false,peopleCount: item.totalUsers ?? 0, eventType: "", eventList: []))
            }
        }
        
        
        //        for item in pepoleLocations {
        //            self.locations.append(EventsLocation(location:  item, markerIcon: "markerLocations_ic", typelocation: "people", eventsCount: 1, markerId: "1",isEvent: false,peopleCount: 1, eventType: "", eventList: []))
        //        }
        
        DispatchQueue.main.async {
            for item in self.locations {
                self.createMarker(for: item.location, markerIcon: item.markerIcon, typelocation: item.typelocation, markerID: item.markerId, eventsCount: item.eventsCount,isEvent: item.isEvent,peopleCount: item.peopleCount, eventTypee: item.eventType)
            }
        }
        
        print("locationCount = \(locations.count)")
    }
    
    //create markers for locations events
    func createMarker(for position:CLLocationCoordinate2D , markerIcon:String?,typelocation:String,markerID:String,eventsCount:Int,isEvent: Bool,peopleCount: Int,eventTypee:String)  {
        
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
        
        if isEvent {
            if eventTypee == "Whitelabel" {
                marker.icon = createMarkerImage(isWhiteLabel: true, iconMarker: markerIcon!, count: "")
            }else if eventTypee == "Private" {
                marker.icon = createMarkerImage(isWhiteLabel: false, iconMarker: markerIcon!, count: "")
            }else {
                marker.icon = createMarkerImage(isWhiteLabel: false, iconMarker: markerIcon!, count: "\(eventsCount)")
            }
        }else {
            marker.icon = createMarkerImage(isWhiteLabel: false, iconMarker: markerIcon!, count: "")
        }
        
        marker.map = mapView
    }
    
    func createMarkerImage(isWhiteLabel:Bool,iconMarker:String,count: String) -> UIImage {
        
        let color = UIColor.black
        let string = count //"\(UInt(count))"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let font = UIFont(name: "Montserrat-Medium", size: 8)
        let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: color,.font : font!,.paragraphStyle:paragraphStyle]
        let attrStr = NSAttributedString(string: string, attributes: attrs)
        
        let imageView:UIImageView = UIImageView()
        
        if isWhiteLabel == true {
            imageView.image = convertToImage(imagURL: iconMarker)
        }else {
            imageView.image = UIImage(named: iconMarker)
        }
        
        UIGraphicsBeginImageContext(CGSize(width: 32, height: 32))
        
        //        UIGraphicsBeginImageContextWithOptions(CGSize(width: 32, height: 32), false, 0.0)
        
        imageView.image?.draw(in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(32), height: CGFloat(32)))
        
        let rect = CGRect(x: CGFloat(Defaults.isIPhoneLessThan2500 ? 4 : 0), y: CGFloat(8), width: CGFloat(Defaults.isIPhoneLessThan2500 ? 24 : 32), height: CGFloat(Defaults.isIPhoneLessThan2500 ? 24 : 32))
        
        attrStr.draw(in: rect)
        
        let markerImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return markerImage
    }
    
    
    func setupFilterDateViews(didselect:String) {
        if didselect == "ThisDay" {
            todayBtn.isSelected = true
            thisWeekBtn.isSelected = false
            thisMonthBtn.isSelected = false
            customBtn.isSelected = false
            todayBtn.backgroundColor = UIColor.FriendzrColors.primary
            todayBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 0.5)
            thisWeekBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisMonthBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            customBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisWeekBtn.backgroundColor = .clear
            thisMonthBtn.backgroundColor = .clear
            customBtn.backgroundColor = .clear
            dateView.isHidden = true
        }
        else if didselect == "ThisWeek" {
            todayBtn.isSelected = false
            thisWeekBtn.isSelected = true
            thisMonthBtn.isSelected = false
            customBtn.isSelected = false
            todayBtn.backgroundColor = .clear
            thisWeekBtn.backgroundColor = UIColor.FriendzrColors.primary
            thisWeekBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
            todayBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisMonthBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            customBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisMonthBtn.backgroundColor = .clear
            customBtn.backgroundColor = .clear
            
            dateView.isHidden = true
        }
        else if didselect == "ThisMonth" {
            todayBtn.isSelected = false
            thisWeekBtn.isSelected = false
            thisMonthBtn.isSelected = true
            customBtn.isSelected = false
            todayBtn.backgroundColor = .clear
            thisWeekBtn.backgroundColor = .clear
            thisMonthBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
            todayBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisWeekBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            customBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisMonthBtn.backgroundColor = UIColor.FriendzrColors.primary
            customBtn.backgroundColor = .clear
            
            dateView.isHidden = true
        }
        else if didselect == "Custom" {
            todayBtn.isSelected = false
            thisWeekBtn.isSelected = false
            thisMonthBtn.isSelected = false
            customBtn.isSelected = true
            todayBtn.backgroundColor = .clear
            thisWeekBtn.backgroundColor = .clear
            thisMonthBtn.backgroundColor = .clear
            customBtn.setBorder(color: UIColor.FriendzrColors.primary?.cgColor, width: 1.0)
            todayBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisWeekBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisMonthBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            customBtn.backgroundColor = UIColor.FriendzrColors.primary
            dateView.isHidden = false
        }
        else {
            todayBtn.isSelected = false
            thisWeekBtn.isSelected = false
            thisMonthBtn.isSelected = false
            customBtn.isSelected = false
            todayBtn.backgroundColor = .clear
            thisWeekBtn.backgroundColor = .clear
            thisMonthBtn.backgroundColor = .clear
            customBtn.backgroundColor = .clear
            
            customBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            todayBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisWeekBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
            thisMonthBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)

            dateView.isHidden = true
        }
        
        
        dateTypeSelected = didselect
//        Defaults.dateTypeSelected = didselect
        
        print("dateTypeSelected = \(dateTypeSelected) = \(Defaults.dateTypeSelected)")
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
        
        todayBtn.cornerRadiusView(radius: 8)
        thisWeekBtn.cornerRadiusView(radius: 8)
        thisMonthBtn.cornerRadiusView(radius: 8)
        customBtn.cornerRadiusView(radius: 8)
        
        todayBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
        thisWeekBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
        thisMonthBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
        customBtn.setBorder(color: UIColor.black.cgColor, width: 1.0)
        
        startDateView.cornerRadiusView(radius: 8)
        startDateView.setBorder(color: UIColor.black.cgColor, width: 1.0)
        endDateView.cornerRadiusView(radius: 8)
        endDateView.setBorder(color: UIColor.black.cgColor, width: 1.0)

        setupFilterDateViews(didselect: "")
        
        DispatchQueue.main.async {
            self.setupDatePickerForStartDate()
        }
        
//        startDateTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
//        endDateTxt.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))

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
//        tableDataSource = GMSAutocompleteTableDataSource()
//        tableDataSource.delegate = self
//        tableView = UITableView(frame: CGRect(x: 0, y:(self.screenSize.height) - (self.screenSize.height - 110), width: self.view.frame.size.width, height: self.view.frame.size.height))
//        tableView.delegate = tableDataSource
//        tableView.dataSource = tableDataSource
//        tableView.isHidden = true
//        view.addSubview(tableView)
        
        //setup events tableView
        eventsByLocationSubView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        shimmerEventsByLocationView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        eventsByLocationTableView.setCornerforTop( withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 21)
        eventsByLocationTableView.register(UINib(nibName: eventCellID, bundle: nil), forCellReuseIdentifier: eventCellID)
        eventsByLocationTableView.isScrollEnabled = true
//        eventsByLocationTableView.separatorStyle = .none
//        eventsByLocationTableView.delegate = self
//        eventsByLocationTableView.dataSource = self
        
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
    
    //update location manager
    func updateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    //setup google map
    func setupGoogleMap(zoom1:Float,zoom2:Float) {
        if Defaults.allowMyLocationSettings {
            self.mapView.delegate = self
            self.mapView.isMyLocationEnabled = true
            self.mapView.isBuildingsEnabled = true
            self.mapView.isIndoorEnabled = true
            
            let lat = Double(Defaults.LocationLat) ?? 0.0
            let lng = Double(Defaults.LocationLng) ?? 0.0
            
            animationZooming(lat, lng, zoom1, zoom2)
            
            LocationZooming.locationLat = lat
            LocationZooming.locationLng = lng
            
            Defaults.availableVC = "MapVC"
            print("availableVC >> \(Defaults.availableVC)")
        }
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> Void)  {
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
//    func CreateSlideUpMenu(_ pos: CLLocationCoordinate2D?) {
//        let widowz = UIApplication.shared.keyWindow
//        transparentView.backgroundColor = .black.withAlphaComponent(0.8)
//        transparentView.frame = self.view.frame
//        widowz?.addSubview(transparentView)
//
//        eventsTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height/2.05)
//        eventsTableView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 40)
//
//        widowz?.addSubview(eventsTableView)
//
//        DispatchQueue.main.async {
//            self.getEventsByMarkerLocation(pos)
//        }
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        transparentView.addGestureRecognizer(tap)
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
//            self.transparentView.alpha = 0.5
//            self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height - self.screenSize.height/2.05, width: self.screenSize.width, height: self.screenSize.height/2.05)
//        }
//    }
    
//    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
//        // handling code
////        DispatchQueue.main.async {
////            self.sliderEventList?.removeAll()
////            self.eventsTableView.reloadData()
////        }
//
//        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
//            self.transparentView.alpha = 0.0
//            self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height/2.05)
//        }
//    }
    
    //MARK: - Actions
    @IBAction func applyBtn(_ sender: Any) {
        if Defaults.token != "" {
            print("catIDs = \(catIDs) \\ \(Defaults.catIDs),\\ \(Defaults.dateTypeSelected)")
            
            Defaults.catIDs = catIDs
            Defaults.catSelectedNames = catSelectedNames
            Defaults.dateTypeSelected = dateTypeSelected
            
            NotificationCenter.default.post(name: Notification.Name("updateFilterBtn"), object: nil, userInfo: nil)
            
            DispatchQueue.main.async {
                self.mapView.clear()
                self.locationsModel.peoplocationDataMV?.removeAll()
                self.locationsModel.eventlocationDataMV?.removeAll()
                self.locations.removeAll()
                self.pepoleLocations.removeAll()
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
        self.dismissKeyboard()
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
        
        showFilterExplainedView.isHidden = true
        switchFilterButton.isUserInteractionEnabled = true
        addEventBtn.isUserInteractionEnabled = true
        sataliteBtn.isUserInteractionEnabled = true
        currentLocationBtn.isUserInteractionEnabled = true
        goAddEventBtn.isUserInteractionEnabled = true
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
    
    @IBAction func todayBtn(_ sender: Any) {
        todayBtn.isSelected = !todayBtn.isSelected
        if todayBtn.isSelected {
            setupFilterDateViews(didselect: "ThisDay")
        }else {
            setupFilterDateViews(didselect: "")
        }
        
        startDateTxt.text = ""
        endDateTxt.text = ""
    }
    
    @IBAction func thisWeekBtn(_ sender: Any) {
        thisWeekBtn.isSelected = !thisWeekBtn.isSelected
        
        if thisWeekBtn.isSelected {
            setupFilterDateViews(didselect: "ThisWeek")
        }else {
            setupFilterDateViews(didselect: "")
        }
        
        startDateTxt.text = ""
        endDateTxt.text = ""
    }
    
    @IBAction func thisMonthBtn(_ sender: Any) {
        thisMonthBtn.isSelected = !thisMonthBtn.isSelected
        if thisMonthBtn.isSelected {
            setupFilterDateViews(didselect: "ThisMonth")
        }else {
            setupFilterDateViews(didselect: "")
        }
        
        startDateTxt.text = ""
        endDateTxt.text = ""
    }
    
    @IBAction func customBtn(_ sender: Any) {
        customBtn.isSelected = !customBtn.isSelected
        
        if customBtn.isSelected {
            setupFilterDateViews(didselect: "Custom")
        }else {
            setupFilterDateViews(didselect: "")
        }
    }
    
    @IBAction func dismissEventsByLocationSuperView(_ sender: Any) {
        viewmodel.events.value?.removeAll()
        self.eventsByLocationSuperView.isHidden = true
        
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
    
    func getEventsByMarkerLocation(_ pos: CLLocationCoordinate2D?) {
        self.shimmerEventsByLocationView.isHidden = false
        AMShimmer.start(for: self.shimmerEventsByLocationView)
        
        viewmodel.getEventsByLoction(lat: pos?.latitude ?? 0.0, lng: pos?.longitude ?? 0.0, CatIds: catIDs, dateCriteria: dateTypeSelected, startDate: startDate, endDate: endDate)
        viewmodel.events.bind { [weak self] value in
            DispatchQueue.main.async {
                    self?.eventsByLocationTableView.delegate = self
                    self?.eventsByLocationTableView.dataSource = self
                    self?.eventsByLocationTableView.reloadData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self?.shimmerEventsByLocationView.isHidden = true
            })
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
                    }
                    else {
//                        for itm in self.locations {
//                            if ((pos?.latitude ?? 0.0 ) == itm.location.latitude) && ((pos?.longitude ?? 0.0) == itm.location.longitude) {
//                                sliderEventList = itm.eventList
//                            }
//                        }
                        
//                        DispatchQueue.main.async {
//                            self.eventsTableView.delegate = self
//                            self.eventsTableView.dataSource = self
//                            self.eventsTableView.reloadData()
//                        }
                        
//                        DispatchQueue.main.async {
//                            self.getEventsByMarkerLocation(pos)
//                        }
                        
                        DispatchQueue.main.async {
//                            self.CreateSlideUpMenu(pos)
                            self.eventsByLocationSuperView.isHidden = false
                            self.shimmerEventsByLocationView.isHidden = false
                            self.viewmodel.events.value?.removeAll()
                            
                            DispatchQueue.main.async {
                                self.getEventsByMarkerLocation(pos)
                            }
                        }
                    }
                }
                else {
                    Router().toOptionsSignUpVC(IsLogout: false)
                }
            }
            else if marker.snippet == "NewEvent" {
                print("NEW EVENT")
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
        
        calRadius(lat: position.target.latitude, lng: position.target.longitude)
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }    
}

//MARK: - UITableViewDelegate
extension MapVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if NetworkConected.internetConect {
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
//                self.eventsByLocationSuperView.alpha = 0.0
//                self.eventsByLocationTableView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height/2.05)
//            }
            
//            let model = sliderEventList?[indexPath.row]
            let model = viewmodel.events.value?[indexPath.row]
            if Defaults.token != "" {
                if model?.eventTypeName == "External" {
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

//MARK: - UICollectionViewDataSource
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
            cell.model = model
            
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
            cell.model = model
            
            cell.HandledetailsBtn = {
                if Defaults.token != "" {
                    if model?.eventTypeName == "External" {
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

//MARK: - UICollectionViewDelegate
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
                        animationZoomingMap(zoomIN: 22, zoomOUT: 12, lat: locitm.latitude, lng: locitm.longitude)
                    }
//                    else {
//                        self.mapView.clear()
//                        self.setupMarkers(model: self.locationsModel)
//                    }
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
}

//MARK: - animation map
extension MapVC {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        calRadius(lat: position.target.latitude, lng: position.target.longitude)
    }
    
    func calRadius(lat:Double,lng:Double) {
        let visibleRegion = mapView.projection.visibleRegion()
        let farLeftLocation = CLLocation(latitude: visibleRegion.farLeft.latitude, longitude: visibleRegion.farLeft.longitude)
        let centerLocation = CLLocation(latitude: lat, longitude: lng)
        
        // Calculate the distance as radius.
        // The distance result from CLLocation is in meters, so we divide it by 1000 to get the value in kilometers
        let radiusKM = (centerLocation.distance(from: farLeftLocation) / 1000.0).rounded(toPlaces: 1)
        // Do something with the radius...
        print("radiusKM \(radiusKM)")
        radiusMLbl.text = "\(radiusKM * 1000) m"
        radiusKMLbl.text = "\(radiusKM) km"

    }
    
    func animationZooming(_ lat: Double, _ lng: Double, _ zoom1: Float, _ zoom2: Float) {
        mapView.camera = GMSCameraPosition.camera(withLatitude: lat,longitude: lng, zoom: zoom1)
        CATransaction.begin()
        CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        let city = GMSCameraPosition.camera(withLatitude: lat,longitude: lng, zoom: zoom2)
        self.mapView.animate(to: city)
        CATransaction.commit()
    }
    
    func animationZoomingMap(zoomIN:Float,zoomOUT:Float,lat:Double,lng:Double) {
        animationZooming(lat, lng, zoomOUT, zoomIN)
        
        LocationZooming.locationLat = lat
        LocationZooming.locationLng = lng
    }
}

