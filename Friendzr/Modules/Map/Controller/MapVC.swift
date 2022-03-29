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

//create location
class EventsLocation {
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var typelocation:String = ""
    var markerIcon:String = ""
    var eventsCount:Int = 0
    var markerId:String = ""
    var isEvent:Bool = false
    var peopleCount:Int = 0
    var eventType:String
    
    init(location:CLLocationCoordinate2D,markerIcon:String,typelocation:String,eventsCount:Int,markerId:String,isEvent:Bool,peopleCount:Int,eventType:String) {
        self.location = location
        self.markerIcon = markerIcon
        self.typelocation = typelocation
        self.eventsCount = eventsCount
        self.markerId = markerId
        self.isEvent = isEvent
        self.peopleCount = peopleCount
        self.eventType = eventType
    }
}

class MapVC: UIViewController ,UIGestureRecognizerDelegate {
    
    //MARK:- Outlets
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
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var upDownViewBtn: UIButton!
    @IBOutlet weak var arrowUpDownImg: UIImageView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var upDownBtn: UIButton!
    @IBOutlet weak var noeventNearbyLbl: UILabel!
    @IBOutlet weak var hideCollectionView: UIView!
    @IBOutlet var hideImgs: [UIImageView]!
    
    //MARK: - Properties
    var locations:[EventsLocation] = [EventsLocation]()
    var location: CLLocationCoordinate2D? = nil
    let locationManager = CLLocationManager()
    var delegate:PickingLocationFromTheMap! = nil
    var currentPlaceMark : CLPlacemark? = nil
    var selectVC:String = ""
    var locationName = ""
    
    var appendNewLocation:Bool = false
    var viewmodel:EventsAroundMeViewModel = EventsAroundMeViewModel()
    var settingVM:SettingsViewModel = SettingsViewModel()
    var genderbylocationVM: GenderbylocationViewModel = GenderbylocationViewModel()
    
    var locationsModel:EventsAroundMeDataModel = EventsAroundMeDataModel()
    
    var transparentView = UIView()
    var eventsTableView = UITableView()
    var eventCellID = "EventsInLocationTableViewCell"
    var nearbyEventCellId = "NearbyEventsCollectionViewCell"
    
    var tableView: UITableView!
    var tableDataSource: GMSAutocompleteTableDataSource!
    
    let screenSize = UIScreen.main.bounds.size
    var isViewUp:Bool = false
    var internetConect:Bool = false
    
    //    var isLocationSettingsAllow:Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        title = "Map".localizedString
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapVC), name: Notification.Name("updateMapVC"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.clear()
        CancelRequest.currentTask = true
        collectionViewHeight.constant = 0
        self.hideCollectionView.isHidden = true
        self.noeventNearbyLbl.isHidden = true
        subViewHeight.constant = 50
        isViewUp = false
        self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationsModel.peoplocationDataMV?.removeAll()
        locationsModel.eventlocationDataMV?.removeAll()
        locations.removeAll()
        mapView.clear()
        
        Defaults.availableVC = "MapVC"
        print("availableVC >> \(Defaults.availableVC)")
        
        appendNewLocation = false
        goAddEventBtn.isHidden = true
        addEventBtn.isHidden = false
        CancelRequest.currentTask = false
        isViewUp = false
        self.arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
        initProfileBarButton()
        
        seyupAds()
        clearNavigationBar()
        
        DispatchQueue.main.async {
            self.updateLocation()
        }
        
        checkLocationPermission()
        
        markerImg.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func seyupAds() {
        bannerView.adUnitID =  URLs.adUnitBanner
        //        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        //        addBannerViewToView(bannerView)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        bannerView.cornerRadiusView(radius: 10)
    }
    
    @objc func updateMapVC() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if Defaults.allowMyLocationSettings == true {
                self.updateUserInterface()
            }
        }
    }
    //MARK: - APIs
    func getEventsOnlyAroundMe() {
        
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
        viewmodel.getAllEventsOnlyAroundMe(lat: Defaults.LocationLat, lng: Defaults.LocationLng, pageNumber: 1)
        viewmodel.eventsOnlyMe.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
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
        viewmodel.getAllEventsAroundMe()
        viewmodel.locations.bind { [unowned self] value in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                print("peoplocationDataCount>> \(value.peoplocationDataMV?.count ?? 0)")
                print("eventlocationDataCount>> \(value.eventlocationDataMV?.count ?? 0)")
                
                self.locationsModel = value
                
                DispatchQueue.main.async {
                    self.setupMarkers(model: self.locationsModel)
                }
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
    
    func getEvents(By lat:Double,lng:Double) {
        
        viewmodel.getEventsByLoction(lat: lat, lng: lng)
        viewmodel.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.eventsTableView.dataSource = self
                self.eventsTableView.delegate = self
                self.eventsTableView.reloadData()
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
    
    //MARK: - Helpers
    func updateUserInterface() {
        
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.internetConect = true
                    self.zoomingStatisticsView.isHidden = false
                    if Defaults.allowMyLocationSettings == true {
                        self.bindToModel()
                    }
                }
            }else {
                DispatchQueue.main.async {
                    self.mapView.clear()
                    self.internetConect = false
                    self.collectionViewHeight.constant = 0
                    self.subView.isHidden = false
                    self.upDownViewBtn.isHidden = true
                    self.zoomingStatisticsView.isHidden = true
                    self.HandleInternetConnection()
                    self.noeventNearbyLbl.isHidden = true
                    self.hideCollectionView.isHidden = true
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
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
    
    var isEventAdmin :Bool = false
    
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
            }else {
                iconMarker = "eventMarker_ic"
            }
            
            locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), markerIcon: iconMarker, typelocation: "event", eventsCount: item.eventData?.count ?? 0, markerId: (item.eventData?.count ?? 0) == 1 ? item.eventData?[0].id ?? "" : "",isEvent: true,peopleCount: 0, eventType: item.event_Type))
        }
        
        DispatchQueue.main.async {
            for item in model.peoplocationDataMV ?? [] {
                self.locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), markerIcon: "markerLocations_ic", typelocation: "people", eventsCount: 1, markerId: "1",isEvent: false,peopleCount: item.totalUsers ?? 0, eventType: ""))
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
        
        if eventTypee == "External" {
            marker.isFlat = true
        }else {
            marker.isFlat = false
        }
        
        if typelocation == "event" {
            if LocationZooming.locationLat == position.latitude && LocationZooming.locationLng == position.longitude {
                marker.appearAnimation = .pop
            }else {
                marker.appearAnimation = .none
            }
        }
        
        var xview:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        
        if Defaults.isIPhoneSmall {
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
        let verticalConstraint = labl.centerYAnchor.constraint(equalTo: xview.centerYAnchor, constant: Defaults.isIPhoneSmall == true ? -2 : -5)
        let widthConstraint = labl.widthAnchor.constraint(equalToConstant: xview.bounds.width)
        let heightConstraint = labl.heightAnchor.constraint(equalToConstant: xview.bounds.height)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        
        if isEvent && eventTypee != "Private" {
            marker.iconView = xview
        }else {
            marker.icon = UIImage(named: markerIcon!)
        }
        
        marker.map = mapView
    }
    
    func setupViews() {
        //setup search bar
        addEventBtn.cornerRadiusView(radius: 10)
        goAddEventBtn.cornerRadiusView(radius: 10)
        sataliteBtn.cornerRadiusView(radius: 10)
        currentLocationBtn.cornerRadiusView(radius: 10)
        topContainerView.cornerRadiusView(radius: 10)
        
        //        profileImg.cornerRadiusForHeight()
        //        profileImg.sd_setImage(with: URL(string: Defaults.Image), placeholderImage: UIImage(named: "placeHolderApp"))
        profileImg.isHidden = true
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clear
        searchBar.barTintColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
        searchBar.searchTextField.tintColor = .black
        searchBar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        
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
        subView.setCornerforTop()
        
        zoomingStatisticsView.cornerRadiusView(radius: 6)
        
        //        setupSwipeSubView()
        
        for itm in hideImgs {
            itm.cornerRadiusView(radius: 8)
        }
    }
    
    func setupSwipeSubView() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubViewHide), name: Notification.Name("handleSubViewHide"), object: nil)
        
        //        checkLocationPermission()
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
        locationManager.requestWhenInUseAuthorization()
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
            
            self.viewmodel.events.value?.removeAll()
        }
    }
    
    //MARK: - Actions
    @IBAction func addEventBtn(_ sender: Any) {
        checkLocationPermissionBtns()
        if internetConect {
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
    }
    
    @IBAction func goAddEventBtn(_ sender: Any) {
        checkLocationPermissionBtns()
        if Defaults.allowMyLocationSettings {
            if self.appendNewLocation {
                
                //                    DispatchQueue.main.async {
                //                        self.setupMarkerz(for: self.location!, markerIcon: "eventMarker_ic", typelocation: "event", markerID: "", eventsCount: 0,isEvent: true,peopleCount: 0)
                //                    }
                
                //                    DispatchQueue.main.async {
                //                        self.locations.append(EventsLocation(location: self.location!, markerIcon: "eventMarker_ic", typelocation: "event",eventsCount: 0,markerId: "",isEvent: true,peopleCount: 0))
                //                    }
                
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
        if internetConect {
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
        if self.internetConect {
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
        if self.internetConect {
            isViewUp.toggle()
            
            if Defaults.allowMyLocationSettings {
                if isViewUp {
                    print("Up")
                    collectionViewHeight.constant = 140
                    subViewHeight.constant = 190
                    subView.isHidden = false
                    isViewUp = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-down_ic")
                    self.getEventsOnlyAroundMe()
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
        if internetConect {
            var pos: CLLocationCoordinate2D? = nil
            pos = marker.position
            print("locationEvent: \(pos?.latitude ?? 0.0),\(pos?.longitude ?? 0.0)")
            
            if marker.snippet == "event" {
                //Events by location
                if marker.title != "" {
                    if marker.isFlat {
                        DispatchQueue.main.async {
                            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                            vc.eventId = marker.title!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else {
                        DispatchQueue.main.async {
                            guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                            vc.eventId = marker.title!
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }else {
                    getEvents(By: pos?.latitude ?? 0.0, lng: pos?.longitude ?? 0.0)
                    CreateSlideUpMenu()
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
    }
}

//MARK: - CLLocation manager delegate
extension MapVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if internetConect {
            self.location = manager.location?.coordinate
            locationManager.stopUpdatingLocation()
            setupGoogleMap(zoom1: -10, zoom2: 14)
        }else {
            print("NOT NETWORK AVILABLE")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            //check  location permissions
            self.checkLocationPermission()
        }
    }
    
    func checkLocationPermission() {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.updateUserInterface()
                }
                
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
        return viewmodel.events.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = eventsTableView.dequeueReusableCell(withIdentifier: eventCellID, for: indexPath) as? EventsInLocationTableViewCell else {return UITableViewCell()}
        let model = viewmodel.events.value?[indexPath.row]
        cell.eventTitleLbl.text = model?.title
        cell.eventDateLbl.text = model?.eventdate
        cell.joinedLbl.text = "Attendees : \(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
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
        if internetConect {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
                self.transparentView.alpha = 0.0
                self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height/2.05)
            }
            
            let model = viewmodel.events.value?[indexPath.row]
            if model?.eventtype == "External" {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                vc.eventId = model?.id ?? ""
                if model?.key == 1 {
                    vc.isEventAdmin = true
                }else {
                    vc.isEventAdmin = false
                }
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                vc.eventId = model?.id ?? ""
                
                if model?.key == 1 {
                    vc.isEventAdmin = true
                }else {
                    vc.isEventAdmin = false
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

//MARK: - events nearby collection view data source and delegate
extension MapVC:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewmodel.eventsOnlyMe.value?.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nearbyEventCellId, for: indexPath) as? NearbyEventsCollectionViewCell else {return UICollectionViewCell()}
        let model = viewmodel.eventsOnlyMe.value?.data?[indexPath.row]
        
        cell.eventTitleLbl.text = model?.title
        cell.eventDateLbl.text = model?.eventdate
        cell.joinedLbl.text = "Attendees : ".localizedString + "\(model?.joined ?? 0) / \(model?.totalnumbert ?? 0)"
        
        cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "placeHolderApp"))
        
        if model?.eventtype == "External" {
            cell.eventColorView.backgroundColor = UIColor.color("#00284c")
        }else {
            cell.eventColorView.backgroundColor = UIColor.FriendzrColors.primary!
        }
        
        //        cell.detailsBtn.backgroundColor = UIColor.color((model?.color ?? ""))
        cell.detailsBtn.tintColor = UIColor.color((model?.color ?? ""))
        cell.expandLbl.textColor = UIColor.color((model?.color ?? ""))
        cell.eventDateLbl.textColor = UIColor.color((model?.color ?? ""))
        
        cell.HandledetailsBtn = {
            if model?.eventtype == "External" {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "ExternalEventDetailsVC") as? ExternalEventDetailsVC else {return}
                vc.eventId = model?.id ?? ""
                
                if model?.key == 1 {
                    vc.isEventAdmin = true
                }else {
                    vc.isEventAdmin = false
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsViewController") as? EventDetailsViewController else {return}
                vc.eventId = model?.id ?? ""
                
                if model?.key == 1 {
                    vc.isEventAdmin = true
                }else {
                    vc.isEventAdmin = false
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }
}

extension MapVC:UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width/2.1, height: height - 20)
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
        let model = viewmodel.eventsOnlyMe.value?.data
        
        for (index,item) in model!.enumerated() {
            let locitm = CLLocationCoordinate2DMake(item.lat?.toDouble() ?? 0.0, item.lang?.toDouble() ?? 0.0)
            //            (Double(item.lat!)!, Double(item.lang!)!)
            
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

class MapUtil {
    class func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double,metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate
        
        //        let tempRegion = MKCoordinateRegionMakeWithDistance(coordinate, metersLat, metersLong)
        let tempRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: metersLat, longitudinalMeters: metersLong)
        
        let tempSpan = tempRegion.span
        
        tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta
        
        return tempCoord
    }
    
    class func setRadius(radius: Double,withCity city: CLLocationCoordinate2D,InMapView mapView: GMSMapView) {
        
        let range = MapUtil.translateCoordinate(coordinate: city, metersLat: radius * 2, metersLong: radius * 2)
        
        let bounds = GMSCoordinateBounds(coordinate: city, coordinate: range)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 5.0)    // padding set to 5.0
        
        mapView.moveCamera(update)
        
        // location
        let marker = GMSMarker(position: city)
        marker.title = "title"
        marker.snippet = "snippet"
        marker.isFlat = true
        marker.map = mapView
        
        // draw circle
        let circle = GMSCircle(position: city, radius: radius)
        circle.map = mapView
        circle.fillColor = UIColor(red:0.09, green:0.6, blue:0.41, alpha:0.5)
        
        mapView.animate(toLocation: city) // animate to center
    }
}

extension MapVC {
    func addBottomSheetView(scrollable: Bool? = true) {
        let bottomSheetVC = scrollable! ? ScrollableBottomSheetViewController() : BottomSheetViewController()
        
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    // MARK: - Actions
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        // Current Frame
        let frame = subView.frame
        
        switch sender.direction {
        case .up:
            if internetConect{
                print("Up")
                if Defaults.allowMyLocationSettings {
                    collectionViewHeight.constant = 140
                    subViewHeight.constant = 190
                    subView.isHidden = false
                    isViewUp = true
                    arrowUpDownImg.image = UIImage(named: "arrow-white-down_ic")
                    self.getEventsOnlyAroundMe()
                }
                else {
                    collectionViewHeight.constant = 0
                    self.hideCollectionView.isHidden = true
                    self.noeventNearbyLbl.isHidden = true
                    subViewHeight.constant = 50
                    subView.isHidden = false
                    isViewUp = false
                    arrowUpDownImg.image = UIImage(named: "arrow-white-up_ic")
                    
                    createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
                }
            }else {
                HandleInternetConnection()
            }
        case .down:
            if internetConect {
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
