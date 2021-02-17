//
//  WeatherModels.swift
//  WeatherBoy
//
//  Created by Jerry Lai on 2021-02-15.
//  Copyright © 2021 Jerry Lai. All rights reserved.
//

import Foundation

struct HourlyWeather: Hashable {
    var time: String
    var weatherCode: Int
    var temp: Int
    var isNight: Bool
    
}
