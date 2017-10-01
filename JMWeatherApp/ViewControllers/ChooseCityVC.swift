//
//  ChooseCityVC.swift
//  WeatherApp
//
//  Created by Jakub Matuła on 01/10/2017.
//  Copyright © 2017 Jakub Matuła. All rights reserved.
//

import UIKit

class ChooseCityVC: UIViewController {
    // MARK:- Properties
    
    var city: String {
        return cityTextField.text ?? ""
    }
    
    private var fetchedWeather: Weather?
    
    @IBOutlet private weak var cityTextField: UITextField! {
        didSet {
            cityTextField.delegate = self
        }
    }
    
    private lazy var weatherService: WeatherService = {
        let accuWeatherConnection = Connection(session: URLSession.shared)
        let accuWeatherURL = URL(string: Constants.AccuWeatherBaseURL)!
        return AccuWeatherService(connection: accuWeatherConnection, baseURL: accuWeatherURL, APIKey: Constants.AccuWeatherAPIKey)
    }()
    
    // MARK:- VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherService.delegate = self
        navigationItem.title = "Choose city"
    }

    
    // MARK:- User Interaction
    @IBAction func checkWeather(_ sender: UIButton) {
        checkWeather(city: city)
    }
    
    private func checkWeather(city: String){
        guard !city.isEmpty else { print("Uzupelnij miasto"); return }
        weatherService.fetchWeather(forCity: city)
    }

    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "toWeather":
            let currentWeatherVC = segue.destination as! CurrentWeatherVC
            currentWeatherVC.currentWeather = fetchedWeather
        default:
            break
        }
    }

}

//MARK:- UITextFieldDelegate
extension ChooseCityVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkWeather(city: city)
        return true
    }
}

//MARK:- WeatherServiceDelegate
extension ChooseCityVC: WeatherServiceDelegate {
    func finishedFetching(weather: Weather) {
        fetchedWeather = weather
        print("Weather: \(weather)")
        performSegue(withIdentifier: "toWeather", sender: self)
    }
}
