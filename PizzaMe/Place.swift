//
//  Place.swift
//  PizzaMe
//
//  Created by Erick Quintanar on 8/2/18.
//  Copyright © 2018 Erick Quintanar. All rights reserved.
//

import Foundation

struct Place {
    var title:    String
    var address:  String
    var city:     String
    var state:    String
    var phone:    String
    var latitud:  Double
    var longitud: Double
    
    init(title: String, address: String, city: String, state: String, phone: String, latitud: Double, longitud: Double) {
        self.title    = title
        self.address  = address
        self.city     = city
        self.state    = state
        self.phone    = phone
        self.latitud  = latitud
        self.longitud = longitud
    }
}
