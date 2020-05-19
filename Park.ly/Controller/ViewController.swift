//
//  ViewController.swift
//  Park.ly
//
//  Created by Jody Abney on 5/18/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var parkButton: RoundButton!
    @IBOutlet weak var directionsButton: RoundButton!
    
    var parkedCarAnnotation: ParkingSpot?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        checkLocationAuthStatus()
        directionsButton.isEnabled = false
        
        setupLongPress()
        
    }
    
    @IBAction func resetMapCenter(sender: RoundButton) {
        guard let coordinates = LocationService.instance.currentLocation else { return }
        centerMapOnUserLocation(coordinates: coordinates)
        
    }
    
    @IBAction func parkButtonTapped(sender: RoundButton) {
        
        removeOverlays()
        
        guard let coordinates = LocationService.instance.currentLocation else { return }
        if parkedCarAnnotation == nil {
            setupAnnotation(coordinates: coordinates)
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
            directionsButton.isEnabled = true
        } else {
            //TODO: handle removing annotation
            parkButton.setImage(#imageLiteral(resourceName: "parkCar"), for: .normal)
            parkedCarAnnotation = nil
            directionsButton.isEnabled = false
            centerMapOnUserLocation(coordinates: coordinates)
        }
    }
    
    func setupAnnotation(coordinates: CLLocationCoordinate2D) {
        parkedCarAnnotation = ParkingSpot(coordinate: coordinates)
        mapView.addAnnotation(parkedCarAnnotation!)
    }
    
    @IBAction func getDirectionsButtonTapped(sender: RoundButton) {
        guard let userCoordinates = LocationService.instance.currentLocation, let parkedCar = parkedCarAnnotation else { return }
        getDirectionsToCar(userCoordinates: userCoordinates, parkedCarCoordinates: parkedCar.coordinate)
    }
}

extension ViewController: MKMapViewDelegate {
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            print("location authorized")
            self.mapView.showsUserLocation = true
            LocationService.instance.customUserLocDelegate = self
        } else {
            LocationService.instance.locationManager.requestWhenInUseAuthorization()
            print("location authorization requested")
        }
    }
    
    func centerMapOnUserLocation(coordinates: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ParkingSpot {
            let id = "pin"
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.animatesDrop = true
            view.pinTintColor = .red
            view.calloutOffset = CGPoint(x: -8, y: -3)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let coordinates = LocationService.instance.currentLocation, let parkedCarCoordinates = parkedCarAnnotation?.coordinate else { return }
        
        getDirectionsToCar(userCoordinates: coordinates, parkedCarCoordinates: parkedCarCoordinates)
        view.setSelected(false, animated: true)
        
    }
}

extension ViewController: CustomUserLocDelegate {
    
    func userLocationUpdated(location: CLLocation) {
        centerMapOnUserLocation(coordinates: location.coordinate)
    }
}

extension ViewController {
    
    func setupLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPress.minimumPressDuration = 0.75
        self.mapView.addGestureRecognizer(longPress)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            removeOverlays()
            let point = gesture.location(in: self.mapView)
            let coordinates = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            setupAnnotation(coordinates: coordinates)
            
            directionsButton.isEnabled = true
            parkButton.setImage(#imageLiteral(resourceName: "foundCar"), for: .normal)
        }
    }
}


extension ViewController {
    
    func getDirectionsToCar(userCoordinates: CLLocationCoordinate2D,
                            parkedCarCoordinates: CLLocationCoordinate2D) {
        
        removeOverlays()
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: parkedCarCoordinates))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [unowned self] (response, error) in
            guard let route = response?.routes.first else { return }
            self.mapView.addOverlay(route.polyline)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                           edgePadding: UIEdgeInsets(top: 200, left: 50,
                                                                     bottom: 50, right: 50),
                                           animated: true)
            
            // print out turn by turn directions
            for step in route.steps {
                print(step.distance)
                print(step.instructions)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let directionRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        directionRenderer.strokeColor = .systemBlue
        directionRenderer.lineWidth = 5
        directionRenderer.alpha = 0.85
        
        return directionRenderer
    }
    
    func removeOverlays() {
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
    }
}
