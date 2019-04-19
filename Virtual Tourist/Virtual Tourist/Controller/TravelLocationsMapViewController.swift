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
        
        //Adding gesture recognizer with action to add the annotation
        let tapRecognize = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(gestureRecognizer:)))
        tapRecognize.minimumPressDuration = 1
        mapView.addGestureRecognizer(tapRecognize)

        //Adding UserDefaults Persistence to presist the center and zoom of the map.
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("App has launched before")
            
            let latDouble = UserDefaults.standard.double(forKey: "Latitude")
            let lat =  CLLocationDegrees(latDouble)
            let longDouble = UserDefaults.standard.double(forKey: "Longitude")
            let long = CLLocationDegrees(longDouble)
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let latitudeDelta = UserDefaults.standard.double(forKey: "LatitudeDelta")
            let longitudeDelta = UserDefaults.standard.double(forKey: "LongitudeDelta")
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
            
            self.mapView.setRegion(region, animated: true)
            
        } else {
            print("This is the first launch ever!")
            
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            let center = mapView.centerCoordinate
            AppDelegate.longitude = center.longitude
            AppDelegate.latitude = center.latitude
            AppDelegate.latitudeDelta = mapView.region.span.latitudeDelta
            AppDelegate.longitudeDelta = mapView.region.span.longitudeDelta
        }
        
    }
    
    //MARK: Getting the center and zoom when moving in the map
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        AppDelegate.longitude = center.longitude
        AppDelegate.latitude = center.latitude
        AppDelegate.latitudeDelta = mapView.region.span.latitudeDelta
        AppDelegate.longitudeDelta = mapView.region.span.longitudeDelta
    }
    
    //MARK: Displaying Annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    //MARK: The Gesture Recognizer that drops the pin.
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: self.mapView)
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                guard error == nil else {
                    let alertVC = UIAlertController(title: "Couldn't add location", message: "(An error occured and location was not added.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alertVC ,animated: true, completion: nil)
                    return
                }
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                self.mapView.addAnnotation(annotation)
                
            })
            
        }
        
    }

    
}

