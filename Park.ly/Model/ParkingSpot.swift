//
//  ParkingSpot.swift
//  Park.ly
//
//  Created by Jody Abney on 5/18/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit
import MapKit


class ParkingSpot: NSObject, MKAnnotation {
    var title: String? = "We Parked Here"
    var subtitle: String? = "Tap for directions"
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate

    }
    
}

