//
//  ViewController.swift
//  pixel-city
//
//  Created by Sebastian Horatiu on 07/09/2019.
//  Copyright © 2019 Sebastian Horatiu. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    @IBAction func CenterMapBtnWasPressed(_ sender: Any) {
    }
    

}

extension MapVC: MKMapViewDelegate {
    
}
