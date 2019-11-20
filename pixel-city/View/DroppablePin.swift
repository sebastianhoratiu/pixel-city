//
//  DroppablePin.swift
//  pixel-city
//
//  Created by Sebastian Horatiu on 20/11/2019.
//  Copyright © 2019 Sebastian Horatiu. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        
        super.init()
    }
}
