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
    @IBOutlet weak var subView2: UIView!
    @IBOutlet weak var addCaptionView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var addCaptionTxt: UITextField!
    @IBOutlet weak var sendCaptionBtn: UIButton!
    
    @IBOutlet weak var closeSubView2Btn: UIButton!
    
    var location: CLLocationCoordinate2D? = nil
    let locationManager = CLLocationManager()
    var delegate:PickingLocationFromTheMap! = nil
    var currentPlaceMark : CLPlacemark? = nil
    var selectVC:String = ""
    var locationLat:Double = 0.0
    var locationLng:Double = 0.0
    var locationTitle:String = ""
    
    var endDate:Date = Date()

    var endDateStr:String = ""
    var startDateStr:String = ""
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    var onLocationCallBackResponse: ((_ lat: String, _ lng: String,_ locationTitle:String,_ isLiveLocation: Bool,_ captionTxt:String,_ locationPeriod:String,_ startTime:String,_ endTime:String) -> ())?
    
    private var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    
    var liveTimeArray = ["15 Minutes","1 Hour","8 Hours"]
    var liveTime:String = ""
    
    
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
        
        pickerView.selectedRow(inComponent: 0)
    }
    
    //MARK: - Helpers
    func setupViews() {
        subView.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 12)
        subView2.setCornerforTop(withShadow: false, cornerMask: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 12)
        searchView.setBorder()
        searchView.cornerRadiusView(radius: 25)
        shareLocationBtn.cornerRadiusView(radius: 8)
        shareMyCurrentLocationBtn.cornerRadiusView(radius: 8)
        myCurrentLocationBtn.cornerRadiusView(radius: 8)
        addCaptionView.cornerRadiusView(radius: 8)
        addCaptionView.setBorder(color: UIColor.white.cgColor, width: 1)
        sendCaptionBtn.setBorder(color: UIColor.white.cgColor, width: 1)
        sendCaptionBtn.cornerRadiusView()
//        closeSubView2Btn.cornerRadiusView()
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func setupMarker(for position:CLLocationCoordinate2D)  {
        self.mapView.clear()
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(named: "ic_map_marker")
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
        
        let camera = GMSCameraPosition.camera(withLatitude: location!.latitude, longitude: location!.longitude, zoom: 17)
        self.mapView.animate(to: camera)
        self.mapView.animate(toViewingAngle: 10)
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
        onLocationCallBackResponse?(Defaults.LocationLat ,Defaults.LocationLng,self.locationTitle, false,"","","","")
        self.onDismiss()
    }
    
    @IBAction func shareLocationBtn(_ sender: Any) {
        subView2.isHidden = false
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    @IBAction func currentLocationBtn(_ sender: Any) {
        setupGoogleMap()
    }
    
    @IBAction func sendCaptionBtn(_ sender: Any) {
        
        startDateStr = formatter.string(from: Date())

        onLocationCallBackResponse?(Defaults.LocationLat ,Defaults.LocationLng,self.locationTitle, true,addCaptionTxt.text!,liveTime,startDateStr,endDateStr)
        
        subView2.isHidden = true
        self.onDismiss()
    }
    
    @IBAction func closeSubView2Btn(_ sender: Any) {
        subView2.isHidden = true
    }
}

//MARK: - GMSMapViewDelegate
extension ShareLocationVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        self.location = coordinate
//        let camera = GMSCameraPosition.camera(withLatitude: (location?.latitude)!, longitude: (location?.longitude)!, zoom: 17.0)
//        mapView.animate(to: camera)
//        self.setupMarker(for: location!)
//        geocode(latitude: location!.latitude, longitude: location!.longitude) { (PM, error) in
//
//            guard let error = error else {
//                self.currentPlaceMark = PM!
//                self.locationLat = self.location!.latitude
//                self.locationLng = self.location!.longitude
//                self.locationTitle = PM?.name ?? ""
//
//                print("Location Name: \(self.locationTitle)")
//                self.locationNameLbl.text = "Location Name: \(self.locationTitle)"
//                return
//            }
//            self.showAlert(withMessage: error.localizedDescription)
//        }
        
        print("didTapAt")
        
        dismissKeyboard()
        subView2.isHidden = true
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
                self.createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.showsBackgroundLocationIndicator = false
            default:
                break
            }
        } else {
            print("Location services are not enabled")
            //            openSettingApp(message:NSLocalizedString("please.enable.location.services.to.continue.using.the.app", comment: ""))
            self.createSettingsAlertController(title: "", message: "Friendzr needs to access your location to show you Friendzrs and events in your area. Grant permission from your phone’s location settings.".localizedString)
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

extension ShareLocationVC: UIPickerViewDataSource,UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return liveTimeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = liveTimeArray[row]
        return model
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        liveTime = liveTimeArray[row]
        
        let calendar = Calendar.current
        
        if row == 0 {
            endDate = calendar.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        }else if row == 1 {
            endDate = calendar.date(byAdding: .hour, value: 1, to: Date()) ?? Date()

        }else {
            endDate = calendar.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
        }
        
        startDateStr = formatter.string(from: Date())
        endDateStr = formatter.string(from: endDate)
        
        print("endDateStr = \(String(describing: endDateStr))")
        print("startDateStr = \(String(describing: startDateStr))")

        print(liveTime)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        
        if let v = view {
            label = v as! UILabel
        }
        
        label.font = UIFont (name: "Montserrat-Medium", size: 20)
        label.textColor = .white
        label.text =  liveTimeArray[row]
        label.textAlignment = .center
        return label
    }
}
