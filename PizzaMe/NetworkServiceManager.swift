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

//typealias EventsResult = (_ error: Error?, _ events: [Any]) -> Void
typealias PlacesResult = (_ error: Error?, _ places: [Place]) -> Void

class NetworkServiceManager {
    
    static let shared = NetworkServiceManager()
    private let session: URLSession
    
    private init () {
        session = URLSession.shared
    }
    
//    func getPlaces(zipCode: String, completion: @escaping EventsResult) {
    func getPlaces(zipCode: String, completion: @escaping PlacesResult) {
        
        let baseURL = "https://query.yahooapis.com/v1/public/yql?"
        let queryUrl = "q=select+*+from+local.search+where+zip%3D%27\(zipCode)%27+and+query%3D%27pizza%27"
        //https://query.yahooapis.com/v1/public/yql?q=select+*+from+local.search+where+zip%3D%2794085%27+and+query%3D%27pizza%27
        
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
                    let title   = result["Title"]
                    let address = result["Address"]
                    let city    = result["City"]
                    let state   = result["State"]
                    let phone   = result["Phone"]
                    let lat     = result["Latitude"]
                    let lon     = result["Longitude"]
                    
//                    print("")
//                    print("title   :", title.stringValue)
//                    print("address :", address.stringValue)
//                    print("city    :", city.stringValue)
//                    print("state   :", state.stringValue)
//                    print("phone   :", phone.stringValue)
//                    print("lat     :", lat.stringValue)
//                    print("lon     :", lon.stringValue)
                    
                    let place = Place(title: title.string!, address: address.string!, city: city.string!, state: state.string!, phone: phone.string!, latitud: lat.double!, longitud: lon.double!)
                    placesArray.append(place)
                }
                completion(nil, placesArray)
            }
        }
        task.resume()
    }
    
}
