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
    
    
    var body: some View {
        ZStack {
            BackgroundView(topColor: isNight ? .black : .blue, bottomColor: isNight ? .gray : Color("lightBlue"))
            VStack{
                //location
                CityView(city: "\(locationModel.city),\(locationModel.province)")
                
                //weather status
                MainWeatherStatusView(imageName: isNight ? "moon.stars.fill" : "cloud.sun.fill", temperature: locationModel.temperature)
                
                HStack {
                    WeatherDayView(dayOfWeek: "TUE", imageName: "cloud.sun.fill", temperature: 76)
                    WeatherDayView(dayOfWeek: "TUE", imageName: "cloud.sun.fill", temperature: 76)
                    WeatherDayView(dayOfWeek: "TUE", imageName: "cloud.sun.fill", temperature: 76)
                    WeatherDayView(dayOfWeek: "TUE", imageName: "cloud.sun.fill", temperature: 76)
                    WeatherDayView(dayOfWeek: "TUE", imageName: "cloud.sun.fill", temperature: 76)
                }
                Spacer()
                
                
                Button(action: {
                    self.isNight.toggle()
                }, label: {
                    WeatherButtonView()
                })
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherDayView: View {
    
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack {
            Text("\(dayOfWeek)").font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
            Image(systemName: "\(imageName)").renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temperature)°")
                .font(.system(size: 28, weight: .medium))
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
            .font(.system(size: 32, weight: .medium, design: .default))
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
                .frame(width: 180, height: 180)
            Text("\(temperature)°")
                .font(.system(size: 70, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40)
    }
}

struct WeatherButtonView: View {
    
    var body: some View {
        Text("Change Day Time")
            .frame(width: 280, height: 50)
            .background(Color.white)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(10)
    }
}
