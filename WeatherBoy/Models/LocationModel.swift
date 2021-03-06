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
    
    @Published var tempFor7days = [[Int]]()
    
    let calendar = Calendar.current
    
    var currentWeatherCode: Int = 2
    
    var days = [Int]()
    
    //weather status
    
    var weatherCodes = [Int]()
    
    var weatherIconsDay = [2: "cloud.bolt.rain.fill", 3: "cloud.drizzle.fill", 5: "cloud.rain.fill", 6: "cloud.snow.fill", 7: "sun.haze.fill", 8: "cloud.sun.fill", 800: "sun.max.fill"]
    
    var weatherIconsNight = [2: "cloud.bolt.rain.fill", 3: "cloud.drizzle.fill", 5: "cloud.rain.fill", 6: "cloud.snow.fill", 7: "cloud.fog.fill", 8: "cloud.moon.fill", 800: "moon.stars.fill"]
    
    var isNight: Bool = false
    
    var weatherInfo = [[Int]]()
    
    var hourlyWeatherInfo = [HourlyWeather]()
    
    //location
    
    private let locationManager = CLLocationManager()
    
    private let geocoder = CLGeocoder()
    
    private var authStatus = CLLocationManager.authorizationStatus()
    
    private var location: CLLocation?
    
    //current weather details
    var currentWeatherDetails: CurrentWeatherInfo = CurrentWeatherInfo(sunrise: "7:00AM", sunset: "6:00PM", humidity: 1, wind_speed: 11, feels_like: 12, uvi: 1, pressure: 1, visibility: 1.6)
    
    override init() {
        super.init()
        locationManager.delegate = self
        configureLocation()
        getHourlyForeCast()
        getCurrentWeatherInfo()
    }
    
    func getCurrentWeatherInfo(){
        
        guard let location = locationManager.location else {
            return
        }
        
        AF.request("https://api.openweathermap.org/data/2.5/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=daily,minutely,alerts,hourly&appid=\(API_KEY)&units=metric").responseJSON { (response) in
            
            if response.error == nil {
                do {
                    let json = try? JSON(data: response.data!)
                    let currentInfo = json!["current"]
                    
                    let humidity = Int(Double(currentInfo["humidity"].stringValue)!)
                    let feels_like = Int(Double(currentInfo["feels_like"].stringValue)!)
                    let wind_speed = Int(Double(currentInfo["wind_speed"].stringValue)!*2.24)
                    let pressure = Int(Double(currentInfo["pressure"].stringValue)!*0.029529983071445)
                    let uvi = Int(Double(currentInfo["uvi"].stringValue)!)
                    let visibility = Double(currentInfo["visibility"].stringValue)!/1600
                    let sunset = Double(currentInfo["sunset"].stringValue)!
                    let sunrise = Double(currentInfo["sunrise"].stringValue)!
                    
                    let riseTime = NSDate(timeIntervalSince1970: TimeInterval(exactly: sunrise)!)
                    
                    let setTime = NSDate(timeIntervalSince1970: TimeInterval(exactly: sunset)!)
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "H:mma"
                    let formattedRiseTime = formatter.string(from: riseTime as Date)
                    let formattedSetTime = formatter.string(from: setTime as Date)
                    
                    self.currentWeatherDetails = CurrentWeatherInfo(sunrise: formattedRiseTime, sunset: formattedSetTime, humidity: humidity, wind_speed: wind_speed, feels_like: feels_like, uvi: uvi, pressure: pressure, visibility: visibility)
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func getTemperature(city: String){
        
        AF.request("https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(API_KEY)&units=metric").responseJSON { (response) in
            
            if response.error == nil {
                do {
                    let json = try? JSON(data: response.data!)
                    let temp = Double(json!["main"]["temp"].stringValue)
                    self.temperature = Int(temp!)
                    if Int(json!["weather"][0]["id"].stringValue)! == 800 {
                        self.currentWeatherCode = Int(json!["weather"][0]["id"].stringValue)!
                    } else {
                        
                        self.currentWeatherCode = Int(json!["weather"][0]["id"].stringValue)!/100
                    }
                    
                    
                    let time = NSDate().timeIntervalSince1970
                    let interval = TimeInterval(time)
                    let hour = self.calendar.component(.hour, from: Date())
                    if hour < 6 || hour >= 18 {
                        self.isNight = true
                    } else {
                        self.isNight = false
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        }
        
    }
    
    func getHourlyForeCast() {
        
        guard let location = locationManager.location else {return}
        
        AF.request("https://api.openweathermap.org/data/2.5/onecall?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&exclude=daily,minutely,alerts,current&appid=\(API_KEY)&units=metric").responseJSON { (response) in
            
            if response.error == nil {
                do {
                    let json = try? JSON(data: response.data!)
                    var hours = json!["hourly"].array
                    var hoursWeather = hours![0...23]
                    for item in hoursWeather {
                        let temp = Int(Double(item["temp"].stringValue)!)
                        let weatherCode = Int(item["weather"][0]["id"].stringValue)
                        let time = Double(item["dt"].stringValue)
                        
                        let date = NSDate(timeIntervalSince1970: TimeInterval(exactly: time!)!)
                        
                        let hour = self.calendar.component(.hour, from: date as Date)
                        
                        var nightTime = false
                        if hour < 6 || hour >= 18 {
                            nightTime = true
                        } else {
                            nightTime = false
                        }
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HHa"
                        let formattedDate = dateFormatter.string(from: date as Date)
       
                        if weatherCode! == 800 {
                            let weather = HourlyWeather(time: formattedDate, weatherCode: 800, temp: temp, isNight: nightTime)
                            self.hourlyWeatherInfo.append(weather)
                        } else {
                            let weather = HourlyWeather(time: formattedDate, weatherCode: weatherCode!/100, temp: temp, isNight: nightTime)
                            self.hourlyWeatherInfo.append(weather)
                        }
                        
                    }
                    
                    
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
                        let minTemp = Int(Double(dailyForcasts![i]["temp"]["min"].stringValue)!)
                         let maxTemp = Int(Double(dailyForcasts![i]["temp"]["max"].stringValue)!)
                        self.tempFor7days.append([minTemp, maxTemp])
                        if Int(dailyForcasts![i]["weather"][0]["id"].stringValue)! == 800 {
                            self.weatherCodes.append(800)
                        } else {
                            self.weatherCodes.append(Int(dailyForcasts![i]["weather"][0]["id"].stringValue)!/100)
                        }
                        
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
        if authStatus == .notDetermined || authStatus == .denied {
            locationManager.requestAlwaysAuthorization()
        } else if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse{
            
            guard let location = self.location else {return}
            geocoder.reverseGeocodeLocation(location) { (place, error) in
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard let location = locationManager.location?.coordinate else {
            return
        }
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
                            
                            self.weatherInfo.append([self.tempFor7days[i][0], self.days[i], self.weatherCodes[i], self.tempFor7days[i][1]])
                        }
                    }
                }
                
                
            }
        }
    }
}
