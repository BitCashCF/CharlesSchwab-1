//
//  LocationManager.swift
//  PizzaMe
//
//  Created by Erick Quintanar on 8/2/18.
//  Copyright © 2018 Erick Quintanar. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationManagerError : Error {
    case noPermission
    case locationFailed
}

typealias LocationComplete = (CLLocation?, Error?) -> ()

class LocationManager : NSObject {
    
    private var manager : CLLocationManager
    private var didUpdateLocation:Bool
    static var shared = LocationManager()
    
    private var locationHandler:LocationComplete?
    var location:CLLocation? {
        didSet {
            guard let loc = location else {
                locationHandler?(location, LocationManagerError.locationFailed)
                return
            }
            locationHandler?(loc, nil)
        }
    }
    
    private override init() {
        self.manager = CLLocationManager()
        self.didUpdateLocation = false
        self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func updateLocation(complete: LocationComplete?) {
        self.locationHandler = complete
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
        if locationServicesEnabled() {
            self.didUpdateLocation = false
            self.manager.startUpdatingLocation()
        }
    }
    
    private func locationServicesEnabled() -> Bool  {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
}

extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.didUpdateLocation { return }
        self.didUpdateLocation = true
        
        self.location = locations.first
        self.manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.manager.stopUpdatingLocation()
        if locationServicesEnabled() {
            locationHandler?(nil, LocationManagerError.locationFailed)
        } else {
            locationHandler?(nil, LocationManagerError.noPermission)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.updateLocation(complete: locationHandler)
    }
}
