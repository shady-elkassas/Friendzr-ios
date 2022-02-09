//
//  EventMapTableViewCell.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 09/02/2022.
//

import UIKit
import GoogleMaps

class EventMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var directionBtn: UIButton!
    
    var parentvc = UIViewController()
    var HandleDirectionBtn: (() -> ())?
    var locationTitle = ""
    var model:Event? = Event()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.cornerRadiusView(radius: 12)        
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupGoogleMap(location:CLLocationCoordinate2D) {
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.isBuildingsEnabled = true
        self.mapView.isIndoorEnabled = true
        self.mapView.isUserInteractionEnabled = false
        
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: 16.0)
        self.mapView.animate(to: camera)
        
        geocode(latitude: location.latitude, longitude: location.longitude) { (PM, error) in
            
            guard let error = error else {
                self.locationTitle = PM?.name ?? ""
                self.setupMarker(for: location)
                return
            }
            
            self.parentvc.showAlert(withMessage: error.localizedDescription)
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
   
    func setupMarker(for position:CLLocationCoordinate2D)  {
        self.mapView.clear()
        let marker = GMSMarker(position: position)
        marker.icon = UIImage(systemName: "default_marker.png")
        marker.title = locationTitle
        marker.map = mapView
    }
    
    @IBAction func directionBtn(_ sender: Any) {
        HandleDirectionBtn?()
    }
}

extension EventMapTableViewCell : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard let rootViewController = Initializer.getWindow().rootViewController else {
            return
        }
        let tabBarController = rootViewController as? UITabBarController
        tabBarController?.selectedIndex = 1
    }
}
