//
//  DetailsAndMapViewController.swift
//  PizzaMe
//
//  Created by Erick Quintanar on 8/3/18.
//  Copyright © 2018 Erick Quintanar. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class DetailsAndMapViewController: UIViewController {

    var placeDetails: Place?
    var postalCode: String?
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placePhoneNumberLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        placeNameLabel.text = placeDetails?.title
        let address = placeDetails?.address ?? ""
        let city = placeDetails?.city ?? ""
        let state = placeDetails?.state ?? ""
        let fullAddress = address + " " + city + " " + state
        placeAddressLabel.text = fullAddress
        placePhoneNumberLabel.text = placeDetails?.phone
        
        let placeAnnotation = MKPointAnnotation()
        if let placeLat = placeDetails?.latitud, let placeLon = placeDetails?.longitud {
            placeAnnotation.coordinate = CLLocationCoordinate2D(latitude: placeLat, longitude: placeLon)
            mapView.setCenter(placeAnnotation.coordinate, animated: true)
            mapView.addAnnotation(placeAnnotation)
            
            var mapRegion = MKCoordinateRegion()
            
            mapRegion.center = placeAnnotation.coordinate
            mapRegion.span.latitudeDelta = 0.01
            mapRegion.span.longitudeDelta = 0.01
            
            mapView.setRegion(mapRegion, animated: true)
            
        }
        
    }

    @IBAction func makeCallButtonAction(_ sender: Any) {
        
        if let phoneNumber = placeDetails?.phone {
            let filterPhoneNumber = phoneNumber.unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
            let normalizedNumber = String(String.UnicodeScalarView(filterPhoneNumber))
            
            guard let number = URL(string: "tel://" + normalizedNumber) else { return }
            UIApplication.shared.open(number)
        }
    }
    
    @IBAction func getDirectionsOnMaps(_ sender: Any) {
        
        if let lat = placeDetails?.latitud, let lon = placeDetails?.longitud {
            
            let latitude: CLLocationDegrees = lat
            let longitude: CLLocationDegrees = lon
            
            let address = [CNPostalAddressStreetKey: placeDetails?.address, CNPostalAddressCityKey: placeDetails?.city, CNPostalAddressPostalCodeKey: postalCode, CNPostalAddressISOCountryCodeKey: "US"]
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: address)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = placeDetails?.title
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
