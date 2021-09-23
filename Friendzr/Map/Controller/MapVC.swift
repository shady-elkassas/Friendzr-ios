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

//select location
protocol PickingLocationFromTheMap {
    func selectLocation(With placeMark:CLPlacemark,location:CLLocationCoordinate2D)
}

//create location
class EventsLocation {
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var titleLocation:String = ""
    
    init(location:CLLocationCoordinate2D,titleLocation:String) {
        self.location = location
        self.titleLocation = titleLocation
    }
}

class MapVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addEventBtn: UIButton!
    
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
    
    var transparentView = UIView()
    var eventsTableView = UITableView()
    //    var eventsTableViewHeight:CGFloat = 400
    var eventCellID = "EventsInLocationTableViewCell"
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    let screenSize = UIScreen.main.bounds.size
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Map".localizedString
        updateLocation()
        initProfileBarButton()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.clear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appendNewLocation = false
        bindToModel()
    }
    
    //MARK:- APIs
    func bindToModel() {
        viewmodel.getAllEventsAroundMe()
        viewmodel.locations.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                setupMarkers()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    func getEvents(By lat:Double,lng:Double) {
        viewmodel.getEventByLoction(lat: lat, lng: lng)
        viewmodel.events.bind { [unowned self] value in
            DispatchQueue.main.async {
                self.hideLoading()
                self.eventsTableView.dataSource = self
                self.eventsTableView.delegate = self
                self.eventsTableView.reloadData()
            }
        }
        
        // Set View Model Event Listener
        viewmodel.error.bind { [unowned self]error in
            DispatchQueue.main.async {
                self.hideLoading()
                self.showAlert(withMessage: error)
            }
        }
    }
    
    //MARK:- Helpers
    
    // locations markers
    func setupMarkers() {
        let model = viewmodel.locations.value
        locations.removeAll()
        for item in model ?? [] {
            locations.append(EventsLocation(location: CLLocationCoordinate2D(latitude: item.lat ?? 0.0, longitude: item.lang ?? 0.0), titleLocation: ""))
        }
        
        for item in locations {
            setupMarker(for: item.location, locTitle: item.titleLocation)
        }
    }
    
    //create markers for locations events
    func setupMarker(for position:CLLocationCoordinate2D , locTitle:String?)  {
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude,longitude: position.longitude,zoom: 15)
        
        if appendNewLocation {
            mapView.clear()
        }
        
        mapView.setMinZoom(15, maxZoom: 15)
        
        self.mapView.camera = camera
        let marker = GMSMarker(position: position)
        //        marker.title = "locTitle"
        marker.icon = UIImage.init(named: "pin")
        
        marker.map = mapView
    }
    
    
    func setupViews() {
        //setup search bar
        addEventBtn.cornerRadiusForHeight()
        searchBar = UISearchBar(frame: CGRect(x: 0, y: (self.screenSize.height) - (self.screenSize.height - 95), width: self.view.bounds.size.width, height: 56.0))
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)
        
        //setup search tableView
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        tableView = UITableView(frame: CGRect(x: 0, y:(self.screenSize.height) - (self.screenSize.height - 150), width: self.view.frame.size.width, height: self.view.frame.size.height - 44))
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
    }
    
    //create marker for location selected
    func setupMarker(for position:CLLocationCoordinate2D)  {
        self.mapView.clear()
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "pin")
        marker.map = mapView
    }
    
    //update location manager
    private func updateLocation () {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    //setup google map
    private func setupGoogleMap() {
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.isBuildingsEnabled = true
        self.mapView.isIndoorEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: location!.latitude, longitude: location!.longitude, zoom: 15.0)
        self.mapView.animate(to: camera)
        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
            
            guard let error = error else {
                self.locationName = (PM?.name)!
                self.setupMarker(for: self.location!, locTitle: PM?.name)
                print(self.locationName)
                print("\(self.location!.latitude) : \(self.location!.longitude)")
                self.currentPlaceMark = PM!
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
    
    //create alert when user not access location
    func createSettingsAlertController(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {_ in
            self.onPopup()
        })
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
        }
    }
    
    //MARK:- Actions
    @IBAction func addEventBtn(_ sender: Any) {
        self.appendNewLocation = true
        self.showAlert(withMessage: "Please pick the event location")
    }
}

//MARK:- GMSMapViewDelegate
extension MapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.location = coordinate
        let camera = GMSCameraPosition.camera(withLatitude: (location?.latitude)!, longitude: (location?.longitude)!, zoom: 17.0)
        mapView.animate(to: camera)
        //        self.setupMarker(for: location!)
        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
            
            guard let error = error else {
                self.locationName = (PM?.name)!
                self.currentPlaceMark = PM!
                
                if self.appendNewLocation {
                    self.setupMarker(for: self.location!, locTitle: (PM?.name)!)
                    
                    self.locations.append(EventsLocation(location: self.location!, titleLocation: (PM?.name)!))
                    self.view.makeToast((PM?.name)!)
                    
                    guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "AddEventVC") as? AddEventVC else {return}
                    vc.locationLat = self.location!.latitude
                    vc.locationLng = self.location!.longitude
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                print(self.locationName)
                print("\(self.location!.latitude) : \(self.location!.longitude)")
                return
            }
            self.showAlert(withMessage: error.localizedDescription)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var locationEvent: CLLocationCoordinate2D? = nil
        locationEvent = marker.position
        print("locationEvent: \(locationEvent?.latitude ?? 0.0),\(locationEvent?.longitude ?? 0.0)")
        
        //Events by location
        getEvents(By: locationEvent?.latitude ?? 0.0, lng: locationEvent?.longitude ?? 0.0)
        CreateSlideUpMenu()
        return true
    }
}


//MARK:- CLLocation manager delegate
extension MapVC : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = manager.location?.coordinate
        locationManager.stopUpdatingLocation()
        setupGoogleMap()
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
                createSettingsAlertController(title: "", message: "Please enable location services to continue using the app".localizedString)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            default:
                break
            }
        } else {
            print("Location services are not enabled")
            createSettingsAlertController(title: "", message: "Please enable location services to continue using the app".localizedString)
        }
    }
}


//MARK:- search in google map tableView dataSource and delegate
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
        
        setupMarker(for: CLLocationCoordinate2D.init(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
        self.locationName = (place.name)!
        print(self.locationName)
        print("\(self.location!.latitude) : \(self.location!.longitude)")
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 17.0)
        self.mapView.animate(to: camera)
        self.searchBar.text = place.name
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


//MARK:- events tableView dataSource and delegate
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
        cell.eventImg.sd_setImage(with: URL(string: model?.image ?? "" ), placeholderImage: UIImage(named: "photo_img"))
        return cell
    }
}

extension MapVC:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.transparentView.alpha = 0.0
            self.eventsTableView.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: self.screenSize.height/2.05)
        }
        
        let model = viewmodel.events.value?[indexPath.row]
        guard let vc = UIViewController.viewController(withStoryboard: .Events, AndContollerID: "EventDetailsVC") as? EventDetailsVC else {return}
        vc.eventId = model?.id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

