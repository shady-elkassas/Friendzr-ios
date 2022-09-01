//
//  ShareLocationVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 25/07/2022.
//

import UIKit
import GoogleMaps
import GooglePlaces

class ShareLocationVC: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var myCurrentLocationBtn: UIButton!
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var shareLocationBtn: UIButton!
    @IBOutlet weak var shareMyCurrentLocationBtn: UIButton!
    
    var location: CLLocationCoordinate2D? = nil
    let locationManager = CLLocationManager()
    var delegate:PickingLocationFromTheMap! = nil
    var currentPlaceMark : CLPlacemark? = nil
    var selectVC:String = ""
    var locationLat:Double = 0.0
    var locationLng:Double = 0.0
    var locationTitle:String = ""

    var onLocationCallBackResponse: ((_ lat: Double, _ lng: Double,_ title:String) -> ())?
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var tableDataSource: GMSAutocompleteTableDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Share Location".localizedString
        setupViews()
        updateLocation()
        setupSearchbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Defaults.availableVC = "SendLocationChatVC"
        print("availableVC >> \(Defaults.availableVC)")

        initCloseBarButton()
        removeNavigationBorder()
        clearNavigationBar()
    }
    
    //MARK: - Helpers
    func setupViews() {
        subView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 25)
        searchView.setBorder()
        searchView.cornerRadiusView(radius: 25)
        shareLocationBtn.cornerRadiusView(radius: 8)
        shareMyCurrentLocationBtn.cornerRadiusView(radius: 8)
        myCurrentLocationBtn.cornerRadiusView(radius: 8)
    }
    
    func setupMarker(for position:CLLocationCoordinate2D)  {
        self.mapView.clear()
        let marker = GMSMarker(position: position)
        marker.icon = UIImage.init(named: "arrow_Select")
        marker.map = mapView
    }
    
    private func updateLocation () {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    //setup google map
    private func setupGoogleMap() {
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.isBuildingsEnabled = true
        self.mapView.isIndoorEnabled = true
        
        location?.latitude = Double(Defaults.LocationLat)!
        location?.longitude = Double(Defaults.LocationLng)!

        let camera = GMSCameraPosition.camera(withLatitude: location!.latitude, longitude: location!.longitude, zoom: 17.0)
        self.mapView.animate(to: camera)
        self.setupMarker(for: location!)
        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
            
            guard let error = error else {
                self.currentPlaceMark = PM!
                self.locationTitle = PM?.name ?? ""
                self.locationLat = self.location!.latitude
                self.locationLng = self.location!.longitude
                self.locationNameLbl.text = "Location Name: \(self.locationTitle)"

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
    
    func setupSearchbar() {
        searchbar.delegate = self
        searchbar.backgroundColor = UIColor.clear
        searchbar.barTintColor = .white
        searchbar.backgroundImage = UIImage()
        searchbar.searchTextField.backgroundColor = .clear
        searchbar.searchTextField.tintColor = .black
        searchbar.searchTextField.font = UIFont(name: "Montserrat-Medium", size: 14)
        searchbar.searchTextField.addDoneOnKeyboard(withTarget: self, action: #selector(dismissKeyboard))
        
        //setup search tableView
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        tableView = UITableView(frame: CGRect(x: 0, y:(screenH) - (screenH - 110), width: self.view.frame.size.width, height: self.view.frame.size.height))
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        tableView.isHidden = true
        view.addSubview(tableView)
    }
    
    
    @IBAction func shareMyCurrentLocationBtn(_ sender: Any) {
        
    }
    @IBAction func shareLocationBtn(_ sender: Any) {
    }
    
    @IBAction func currentLocationBtn(_ sender: Any) {
        setupGoogleMap()
    }
}

//MARK: - GMSMapViewDelegate
extension ShareLocationVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.location = coordinate
        let camera = GMSCameraPosition.camera(withLatitude: (location?.latitude)!, longitude: (location?.longitude)!, zoom: 17.0)
        mapView.animate(to: camera)
        self.setupMarker(for: location!)
        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
            
            guard let error = error else {
                self.currentPlaceMark = PM!
                self.locationLat = self.location!.latitude
                self.locationLng = self.location!.longitude
                self.locationTitle = PM?.name ?? ""
                
                self.locationNameLbl.text = "Location Name: \(self.locationTitle)"
                return
            }
            self.showAlert(withMessage: error.localizedDescription)
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension ShareLocationVC : CLLocationManagerDelegate {
    
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
                createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        } else {
            print("Location services are not enabled")
            //            openSettingApp(message:NSLocalizedString("please.enable.location.services.to.continue.using.the.app", comment: ""))
            createSettingsAlertController(title: "", message: "We are unable to use your location to show Friendzrs in the area. Please click below to consent and adjust your settings".localizedString)
        }
    }
}

//MARK: - search in google map tableView dataSource and delegate
extension ShareLocationVC: UISearchBarDelegate {
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

extension ShareLocationVC: GMSAutocompleteTableDataSourceDelegate {
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
        self.locationTitle = (place.name)!
        print(self.locationTitle)
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

