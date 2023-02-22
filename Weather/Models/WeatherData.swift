//
//  WeatherData.swift
//  Weather
//
//  Created by Dmitrii Tikhomirov on 2/21/23.
//

import Foundation

struct WeatherData: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
}
