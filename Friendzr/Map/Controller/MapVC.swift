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

protocol PickingLocationFromTheMap {
    func selectLocation(With placeMark:CLPlacemark,location:CLLocationCoordinate2D)
}

class EventsLocation {
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var titleLocation:String = ""
    
    init(location:CLLocationCoordinate2D,titleLocation:String) {
        self.location = location
        self.titleLocation = titleLocation
    }
}

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addEventBtn: UIButton!
    
    var locations:[EventsLocation] = [EventsLocation]()
    var location: CLLocationCoordinate2D? = nil
    let locationManager = CLLocationManager()
    var delegate:PickingLocationFromTheMap! = nil
    var currentPlaceMark : CLPlacemark? = nil
    var selectVC:String = ""
    var locationVVVV = ""
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    
    var appendNewLocation:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(GMSServices.openSourceLicenseInfo())
        
        self.title = "Map".localizedString
        updateLocation()
        setupViews()
        initProfileBarButton()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.clear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appendNewLocation = false
        setupMARKERS()
    }
    
    func setupMARKERS() {
        locations.removeAll()

        locations.append(EventsLocation(location: (CLLocationCoordinate2D(latitude: 31.205753, longitude: 31.205753)), titleLocation: ""))
        locations.append(EventsLocation(location: (CLLocationCoordinate2D(latitude: 31.20530336842649, longitude: 29.924357905983925)), titleLocation: ""))
        locations.append(EventsLocation(location: (CLLocationCoordinate2D(latitude: 31.20575932707811, longitude: 29.920976981520653)), titleLocation: ""))
        locations.append(EventsLocation(location: (CLLocationCoordinate2D(latitude: 31.205753, longitude: 31.205753)), titleLocation: ""))
        locations.append(EventsLocation(location: (CLLocationCoordinate2D(latitude: 31.205900128959676, longitude: 29.921999908983704)), titleLocation: ""))

        for item in locations {
            setupMarker(for: item.location, locTitle: item.titleLocation)
        }
    }
    
    func setupMarker(for position:CLLocationCoordinate2D , locTitle:String?)  {
        let camera = GMSCameraPosition.camera(withLatitude: position.latitude,longitude: position.longitude,zoom: 16)
        
        if appendNewLocation {
            mapView.clear()
        }
        
        self.mapView.camera = camera
        let marker = GMSMarker(position: position)
        marker.title = locTitle
        marker.icon = UIImage.init(named: "pin")
        
        marker.map = mapView
        
    }
    
    func setupViews() {
        addEventBtn.cornerRadiusForHeight()
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 95, width: self.view.frame.size.width, height: 56.0))
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        view.addSubview(searchBar)
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        
        tableView = UITableView(frame: CGRect(x: 0, y: 150, width: self.view.frame.size.width, height: self.view.frame.size.height - 44))
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        tableView.isHidden = true
        view.addSubview(tableView)
    }
    
    func setupMarker(for position:CLLocationCoordinate2D)  {
        self.mapView.clear()
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "pin")
        marker.map = mapView
    }
    
    private func updateLocation () {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    private func setupGoogleMap() {
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.isBuildingsEnabled = true
        self.mapView.isIndoorEnabled = true
        let camera = GMSCameraPosition.camera(withLatitude: location!.latitude, longitude: location!.longitude, zoom: 17.0)
        self.mapView.animate(to: camera)
//        self.setupMarker(for: location!)
        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
            
            guard let error = error else {
                self.locationVVVV = (PM?.name)!
                self.setupMarker(for: self.location!, locTitle: PM?.name)
                
                //                Defaults.currentLocation = PM?.name ?? ""
                print(self.locationVVVV)
                print("\(self.location!.latitude) : \(self.location!.longitude)")
                self.currentPlaceMark = PM!
                //                Defaults.locationLng = self.location!.longitude
                //                Defaults.locationLat = self.location!.latitude
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
    
    
    @IBAction func addEventBtn(_ sender: Any) {
        self.appendNewLocation = true
        self.showAlert(withMessage: "Please pick the event location")
    }
}

extension MapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.location = coordinate
        let camera = GMSCameraPosition.camera(withLatitude: (location?.latitude)!, longitude: (location?.longitude)!, zoom: 17.0)
        mapView.animate(to: camera)
//        self.setupMarker(for: location!)
        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
            
            guard let error = error else {
                self.locationVVVV = (PM?.name)!
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
                
//                Defaults.currentLocation = PM?.name ?? ""
//                Defaults.locationLng = self.location!.longitude
//                Defaults.locationLat = self.location!.latitude
                
                print(self.locationVVVV)
                print("\(self.location!.latitude) : \(self.location!.longitude)")
                return
            }
            self.showAlert(withMessage: error.localizedDescription)
        }
    }
}

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
//                openSettingApp(message:NSLocalizedString("please.enable.location.services.to.continue.using.the.app", comment: ""))
                createSettingsAlertController(title: "", message: "Please enable location services to continue using the app".localizedString)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
            default:
                break
            }
        } else {
            print("Location services are not enabled")
//            openSettingApp(message:NSLocalizedString("please.enable.location.services.to.continue.using.the.app", comment: ""))
            createSettingsAlertController(title: "", message: "Please enable location services to continue using the app".localizedString)
        }
    }
}


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
        // Reload table data.
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
        self.locationVVVV = (place.name)!
//        Defaults.currentLocation = place.name!
//        Defaults.locationLng = place.coordinate.longitude
//        Defaults.locationLat = place.coordinate.latitude
        print(self.locationVVVV)
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
