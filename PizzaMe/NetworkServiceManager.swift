//
//  NetworkServiceManager.swift
//  PizzaMe
//
//  Created by Erick Quintanar on 8/2/18.
//  Copyright © 2018 Erick Quintanar. All rights reserved.
//

import Foundation

enum NetworkingError : Error {
    case requestCreation
    case xmlParsing
    case noInternet
    case noSuccessStatusCode
    case other
}

typealias PlacesResult = (_ error: Error?, _ places: [Place]) -> Void

class NetworkServiceManager {
    
    static let shared = NetworkServiceManager()
    private let session: URLSession
    
    private init () {
        session = URLSession.shared
    }
    
    func getPlaces(zipCode: String, completion: @escaping PlacesResult) {
        
        let baseURL = "https://query.yahooapis.com/v1/public/yql?"
        let queryUrl = "q=select+*+from+local.search+where+zip%3D%27\(zipCode)%27+and+query%3D%27pizza%27"
        
        guard let url = URL(string: baseURL + queryUrl) else {
            completion(NetworkingError.requestCreation, [])
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completion(NetworkingError.other, [])
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(NetworkingError.noSuccessStatusCode, [])
                return
            }
            guard let data = data else {
                completion(nil, [])
                return
            }
            
            // XML Parse Decoder
            if let xmlData = XML(data: data) {
                var placesArray: [Place] = []
                for result in xmlData["results"]["Result"] {
                    let title   = result["Title"].string ?? "No Titlte"
                    let address = result["Address"].string ?? "No Address"
                    let city    = result["City"].string ??  "No City"
                    let state   = result["State"].string ?? "No State"
                    let phone   = result["Phone"].string ?? "No Phone"
                    let lat     = result["Latitude"].double ?? 0.0
                    let lon     = result["Longitude"].double ?? 0.0
                    
                    let place = Place(title: title, address: address, city: city, state: state, phone: phone, latitud: lat, longitud: lon)
                    placesArray.append(place)
                }
                completion(nil, placesArray)
            }
        }
        task.resume()
    }
    
}
