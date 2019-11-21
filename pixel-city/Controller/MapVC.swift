//
//  ViewController.swift
//  pixel-city
//
//  Created by Sebastian Horatiu on 07/09/2019.
//  Copyright © 2019 Sebastian Horatiu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManger = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadiusMeters: Double = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManger.delegate = self
        configureLocationServices()
        addDoubleTap()
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    @IBAction func CenterMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        return pinAnnotation
    }
    
    func centerMapOnUserLocation() {
        guard let currentLocationCoordinate = locationManger.location?.coordinate else { return }
        centerMap(arround: currentLocationCoordinate)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(touchPoint, touchCoordinate)
        
        //This is just for my benefit; I'll probably remove it later
        displayTouchCoordinate(touchPoint, touchCoordinate)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        centerMap(arround: touchCoordinate)
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    fileprivate func displayTouchCoordinate(_ touchPoint: CGPoint, _ touchCoordinate: CLLocationCoordinate2D) {
        let droppedPinAlertController = UIAlertController(title: "Dropped pin", message: "A pin was dropped at: \r- screen coordinates: \(touchPoint); \r- map coordinates: \(touchCoordinate);", preferredStyle: .alert)
        droppedPinAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(droppedPinAlertController, animated: true, completion: nil)
    }
    
    fileprivate func centerMap(arround coordinate: CLLocationCoordinate2D) {
        /*
        This function was not in the lesson
        I've created it because the same code was being used twice
        */
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadiusMeters, longitudinalMeters: regionRadiusMeters)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManger.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
