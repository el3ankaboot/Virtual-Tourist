//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Gamal Gamaleldin on 4/12/19.
//  Copyright © 2019 el3ankaboot. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController , MKMapViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("App has launched before")
            let latDouble = UserDefaults.standard.double(forKey: "Latitude")
            let lat =  CLLocationDegrees(latDouble)
            let longDouble = UserDefaults.standard.double(forKey: "Longitude")
            let long = CLLocationDegrees(longDouble)
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20))
            
            self.mapView.setRegion(region, animated: true)
            
        } else {
            let startingCoordinate = mapView.centerCoordinate
            let latitude = startingCoordinate.latitude
            let longitude = startingCoordinate.longitude
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(longitude, forKey: "Longitude")
            UserDefaults.standard.set(latitude, forKey: "Latitude")
            UserDefaults.standard.set(0.0, forKey: "Zoom")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        AppDelegate.longitude = center.longitude
        AppDelegate.latitude = center.latitude
    }

    
}

