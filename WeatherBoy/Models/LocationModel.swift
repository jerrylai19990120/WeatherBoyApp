//
//  LocationModel.swift
//  WeatherBoy
//
//  Created by Jerry Lai on 2021-02-14.
//  Copyright © 2021 Jerry Lai. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON

class LocationModel: NSObject, ObservableObject {
    
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var city: String = ""
    @Published var province: String = ""
    @Published var country: String = ""
    @Published var temperature: Int = 0
    
    private let locationManager = CLLocationManager()
    
    private let geocoder = CLGeocoder()
    
    private var authStatus = CLLocationManager.authorizationStatus()
    
    private var location: CLLocation?
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        configureLocation()
    }
    
    
    func getTemperature(city: String){
        
        AF.request("https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(API_KEY)&units=metric").responseJSON { (response) in
            
            if response.error == nil {
                do {
                    let json = try? JSON(data: response.data!)
                    let temp = Double(json!["main"]["temp"].stringValue)
                    self.temperature = Int(temp!)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        }
        
        
        
        
    }
    
    
}

extension LocationModel: CLLocationManagerDelegate {
    
    func configureLocation(){
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse{
            
            guard let location = self.location else {return}
            geocoder.reverseGeocodeLocation(location) { (place, error) in
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard let location = locationManager.location?.coordinate else {return}
        latitude = location.latitude
        longitude = location.longitude
        self.location = locationManager.location
        self.geocoder.reverseGeocodeLocation(self.location!) { (placemarks, error) in
            if placemarks!.count > 0 {
                self.city = placemarks![0].locality!
                self.province = placemarks![0].administrativeArea!
                self.country = placemarks![0].country!
                self.getTemperature(city: placemarks![0].locality!)
            }
        }
    }
}
