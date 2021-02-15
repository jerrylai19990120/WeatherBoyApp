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
    
    @Published var tempFor7days = [Int]()
    
    let calendar = Calendar.current
    
    var currentWeatherCode: Int = 2
    
    var days = [Int]()
    
    var weatherCodes = [Int]()
    
    var weatherIconsDay = [2: "cloud.bolt.rain.fill", 3: "cloud.drizzle.fill", 5: "cloud.rain.fill", 6: "cloud.snow.fill", 7: "sun.haze.fill", 8: "cloud.sun.fill", 800: "sun.max.fill"]
    
    var weatherIconsNight = [2: "cloud.bolt.rain.fill", 3: "cloud.drizzle.fill", 5: "cloud.rain.fill", 6: "cloud.snow.fill", 7: "cloud.fog.fill", 8: "cloud.moon.fill", 800: "moon.stars.fill"]
    
    var weatherInfo = [[Int]]()
    
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
                    self.currentWeatherCode = Int(json!["weather"][0]["id"].stringValue)!/100
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        }
        
    }
    
    func getDailyForcast(lat: String, lng: String, completion: @escaping (_ status:Bool)->()) {
        
        AF.request("https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(lng)&exclude=hourly,minutely,current,alerts&appid=\(API_KEY)&units=metric").responseJSON { (response) in
            
            if response.error == nil {
                do {
                    let json = try? JSON(data: response.data!)
                    let dailyForcasts = json!["daily"].array
                    
                    for i in 1...7 {
                        let temp = Int(Double(dailyForcasts![i]["temp"]["day"].stringValue)!)
                        self.tempFor7days.append(temp)
                        self.weatherCodes.append(Int(dailyForcasts![i]["weather"][0]["id"].stringValue)!/100)
                    }
                    completion(true)
                } catch {
                    completion(false)
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
            
            if placemarks == nil {
                return
            }
            
            if placemarks!.count > 0 {
                
                self.city = placemarks![0].locality!
                self.province = placemarks![0].administrativeArea!
                self.country = placemarks![0].country!
                self.getTemperature(city: placemarks![0].locality!)
                let latitude = String(format: "%f", placemarks![0].location!.coordinate.latitude)
                let longitude = String(format: "%f", placemarks![0].location!.coordinate.longitude)
                self.getDailyForcast(lat: latitude, lng: longitude) { (success) in
                    if success {
                        
                        var day = self.calendar.component(.weekday, from: self.calendar.startOfDay(for: Date()))
                        
                        for i in 1...7 {
                            if day < 7 {
                                day += 1
                                self.days.append(day)
                            } else {
                                day = 1
                                self.days.append(day)
                            }
                        }
                        
                        for i in 0...6 {
                            
                            self.weatherInfo.append([self.tempFor7days[i], self.days[i], self.weatherCodes[i]])
                        }
                    }
                }
                
                
            }
        }
    }
}
