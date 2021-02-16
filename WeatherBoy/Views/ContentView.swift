//
//  ContentView.swift
//  WeatherBoy
//
//  Created by Jerry Lai on 2021-02-14.
//  Copyright © 2021 Jerry Lai. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isNight = false
    
    @ObservedObject var locationModel = LocationModel()
    
    var dayOfWeek = [1: "SUN", 2: "MON", 3: "TUE", 4: "WED", 5: "THUR", 6: "FRI", 7: "SAT"]
    
    var weatherStatusOpacity: Double = 1.0
    
    var body: some View {
        
        GeometryReader { gr in
            
            ZStack {
                BackgroundView(topColor: self.locationModel.isNight ? .black : .blue, bottomColor: self.locationModel.isNight ? .gray : Color("lightBlue"))
                VStack{
                    //location
                    CityView(city: "\(self.locationModel.city),\(self.locationModel.province)")
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        //weather status
                        MainWeatherStatusView(imageName: self.locationModel.isNight ? self.locationModel.weatherIconsNight[self.locationModel.currentWeatherCode]! : self.locationModel.weatherIconsDay[self.locationModel.currentWeatherCode]!, temperature: self.locationModel.temperature).opacity(self.weatherStatusOpacity)
                    
                        //divider
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 1)
                            .padding(.bottom, 16)

                        ScrollView(.horizontal, showsIndicators: false) {

                            HStack(spacing: 12) {
                                
                                ForEach(self.locationModel.hourlyWeatherInfo, id: \.self){
                                item in
                                
                                HourlyWeatherView(hourTime: item.time, imageName: item.isNight ? self.locationModel.weatherIconsNight[item.weatherCode]! : self.locationModel.weatherIconsDay[item.weatherCode]!, temperature: item.temp)
                                }
                                
                                /*HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)
                                HourlyWeatherView(hourTime: "10PM", imageName: "cloud.sun.fill", temperature: 18)*/
                                
                                
                                
                            }.padding([.trailing, .leading], 46)
                        }
                        
                        Spacer()
                        
                        ScrollView(showsIndicators: false) {
                            
                            //divider
                            Rectangle()
                            .fill(Color.white)
                                .frame(height: 1)
                                .padding([.bottom, .top], 16)
                            
                            VStack {
                                
                                ForEach(self.locationModel.weatherInfo, id: \.self) { item in
                                
                                WeatherDayForcastView(dayOfWeek: "\(self.dayOfWeek[item[1]]!)", imageName: self.locationModel.isNight ? self.locationModel.weatherIconsNight[item[2]]! : self.locationModel.weatherIconsDay[item[2]]!, temperature: item[0])
                                
                                
                                }/*
                                WeatherDayForcastView(dayOfWeek: "MON", imageName: "cloud.moon.fill", temperature: 18)
                                WeatherDayForcastView(dayOfWeek: "TUE", imageName: "cloud.moon.fill", temperature: 18)
                                WeatherDayForcastView(dayOfWeek: "WED", imageName: "cloud.moon.fill", temperature: 18)
                                WeatherDayForcastView(dayOfWeek: "THUR", imageName: "cloud.moon.fill", temperature: 18)
                                WeatherDayForcastView(dayOfWeek: "FRI", imageName: "cloud.moon.fill", temperature: 18)
                                WeatherDayForcastView(dayOfWeek: "SAT", imageName: "cloud.moon.fill", temperature: 18)
                                WeatherDayForcastView(dayOfWeek: "SUN", imageName: "cloud.moon.fill", temperature: 18)*/
                                                        
                                
                            }.padding([.leading, .trailing], 46)
                                
                            
                        }
                        
                        //divider
                        Rectangle()
                        .fill(Color.white)
                            .frame(height: 1)
                            .padding([.bottom, .top], 16)
                        
                        VStack {
                            
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text("SUNRISE")
                                        .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.sunrise)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.4)
                                
                                
                                
                                VStack(alignment: .leading) {
                                    Text("SUNSET")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.sunset)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.6)
                                
                                
                            }.frame(width: gr.size.width)
                            
                            //divider
                            Rectangle()
                            .fill(Color.white)
                                .frame(width: gr.size.width*0.9,height: 1)
                                .padding([.top, .bottom], 3)

                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text("PRESSURE")
                                        .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.pressure) inHg")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.4)
                                
                                
                                
                                VStack(alignment: .leading) {
                                    Text("HUMIDITY")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.humidity)%")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.6)
                                
                                
                            }.frame(width: gr.size.width)
                            
                            //divider
                            Rectangle()
                            .fill(Color.white)
                                .frame(width: gr.size.width*0.9,height: 1)
                                .padding([.top, .bottom], 3)
                            
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text("WIND")
                                        .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.wind_speed) mph")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.4)
                                
                                
                                
                                VStack(alignment: .leading) {
                                    Text("FEELS LIKE")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.feels_like)°")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.6)
                                
                                
                            }.frame(width: gr.size.width)
                            
                            //divider
                            Rectangle()
                            .fill(Color.white)
                                .frame(width: gr.size.width*0.9,height: 1)
                                .padding([.top, .bottom], 3)
                            
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    Text("VISIBILITY")
                                        .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(String(format: "%.1f", self.locationModel.currentWeatherDetails.visibility)) mi")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.4)
                                
                                
                                
                                VStack(alignment: .leading) {
                                    Text("UV INDEX")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                    Text("\(self.locationModel.currentWeatherDetails.uvi)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                                }.frame(width: gr.size.width*0.6)
                                
                                
                            }.frame(width: gr.size.width)
                            
                        }.padding([.leading, .trailing], 16)
                        
                        //divider
                        Rectangle()
                        .fill(Color.white)
                            .frame(height: 1)
                            .padding([.top, .bottom], 16)
            
                    }
                    

                    
                    
                }
            }

        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HourlyWeatherView: View {
    
    var hourTime: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack {
            Text("\(hourTime)").font(.system(size: 13, weight: .medium, design: .default))
                .foregroundColor(.white)
            Image(systemName: "\(imageName)").renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
            Text("\(temperature)°")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct BackgroundView: View {
    
    var topColor: Color
    var bottomColor: Color
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .topLeading, endPoint: .bottomTrailing).edgesIgnoringSafeArea(.all)
    }
}

struct CityView: View {
    
    var city: String
    
    var body: some View {
        Text(city)
            .font(.system(size: 28, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}

struct MainWeatherStatusView: View {
    
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
            Text("\(temperature)°")
                .font(.system(size: 54, weight: .medium))
                .foregroundColor(.white)
        }
    }
}


struct WeatherDayForcastView: View {
    
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        HStack(spacing: 100){
            Text("\(dayOfWeek)")
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
                .frame(width:88, alignment: .leading)
            
            Image(systemName: "\(imageName)")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text("\(temperature)°")
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
                .frame(width: 46, alignment: .trailing)
        }
    }
}
