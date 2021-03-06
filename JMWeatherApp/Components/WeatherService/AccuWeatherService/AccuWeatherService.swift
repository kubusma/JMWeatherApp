//
//  OpenWeatherService.swift
//  WeatherApp
//
//  Created by Jakub Matuła on 01/10/2017.
//  Copyright © 2017 Jakub Matuła. All rights reserved.
//

import Foundation
import SwiftyJSON

class AccuWeatherService: WeatherService {
    
    var webService: WebSerivce {
        return WebSerivce.shared
    }
    
    func fetchLocation(forCity city: String, completion: @escaping ([Location]?) -> Void) {
        let resource = Location.resource(name: city)
        webService.load(resource: resource, completion: completion)
    }
    
    func fetchWeather(forLocation location: Location, completion: @escaping ([Weather]?) -> Void) {
        tryFetchingWeather(forLocation: location, resourceFunc: Weather.currentConditions(locationKey:), completion: completion)
    }
    
    func fetch12HourForecast(forLocation location: Location, completion: @escaping ([Weather]?) -> Void) {
        tryFetchingWeather(forLocation: location, resourceFunc: Weather.forecast12Hours(locationKey:), completion: completion)
    }
    
    func fetchWeatherIcon(weather: Weather?, completion: @escaping (UIImage?) -> Void) {
        guard let weather = weather else { return }
        webService.load(resource: weather.iconResource, completion: completion)
    }
    
    private func tryFetchingWeather(forLocation location: Location, resourceFunc: @escaping (String) -> Resource<[Weather]>, completion: @escaping ([Weather]?) -> Void) {
        if let key = location.key {
            let resource = resourceFunc(key)
            webService.load(resource: resource, completion: completion)
        } else {
            fetchLocation(forCity: location.name) { locations in
                guard let location = locations?.first else { completion(nil); return }
                self.tryFetchingWeather(forLocation: location, resourceFunc: resourceFunc) { weathers in
                    guard let weathers = weathers else { completion(nil); return}
                    let weathersWithLocation = weathers.map({ (weather: Weather) -> Weather in
                        var weather = weather
                        weather.location = location
                        return weather
                    })
                    completion(weathersWithLocation)
                }
            }
        }
    }
}
