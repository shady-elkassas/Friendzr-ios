//
//  ExtensionMapKit.swift
//  Friendzr
//
//  Created by Muhammad Sabri Saad on 31/01/2022.
//

import UIKit
import MapKit

extension MKMapItem {
    convenience init(coordinate: CLLocationCoordinate2D, name: String) {
        self.init(placemark: .init(coordinate: coordinate))
        self.name = name
    }
}
//  let source = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Source")
//  let destination = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Destination")
//
//MKMapItem.openMaps(
//    with: [source, destination],
//    launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//)

