//
//  Extensions + MapVC.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 15/12/2021.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import ObjectMapper
import MapKit

//MARK: - Draw Google API Dirction
extension MapVC {
    func getTotalDistance(destination:String) {
        let origin = "\(Defaults.LocationLat),\(Defaults.LocationLng)"
        let destination = destination
        
        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(origin)&destination=\(destination)&units=imperial&mode=driving&language=en-EN&sensor=fasle&key=\(googleApiKey)"
        
        let url = URL(string: urlString)
        
        URLSession.shared.dataTask(with: url!) { (data,response,error) in
            
            if error != nil {
                print(error!)
            }else {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let rows = json[ "rows"] as! NSArray
                    print(rows)
                    let dic = rows[0] as! Dictionary<String,Any>
                    let elements = dic["elements"] as! NSArray
                    let dis = elements[0] as! Dictionary<String,Any>
                    let distanceMiles = dis["distance"] as! Dictionary<String, Any>
                    let miles = distanceMiles["text"]! as! String
                    let TimeRide = dis["duration"] as! Dictionary<String,Any>
                    let finalTime = TimeRide[ "text"]! as! String
                    
                    
                    print(finalTime,miles)
                    
                }
                catch let error as NSError {
                    print("error >> \(error)")
                }
            }
        }.resume()
    }
    
    
    func drawGoogleAPIDirction(destination:String) {
        let origin = "\(Defaults.LocationLat),\(Defaults.LocationLng)"
        let destination = destination
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode-driving&key=\(googleApiKey)"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            }else {
                DispatchQueue.main.async {
                    self.mapView.clear()
                    //                    self.addSourceDestinationMarkers()
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    let routes = json["routes"] as! NSArray
                    self.getTotalDistance(destination: destination)
                    
                    OperationQueue.main.addOperation({
                        for route in routes {
                            let route0verviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            
                            let points = route0verviewPolyline.object(forKey: "points")
                            let path = GMSPath.init (fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: path)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = UIColor.pink
                            let bounds = GMSCoordinateBounds (path: path!)
                            self.mapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30))
                            polyline.map = self.mapView
                        }
                    })
                }
                catch let error as NSError {
                    print("error >> \(error)")
                }
                
            }
        }.resume()
    }
}

