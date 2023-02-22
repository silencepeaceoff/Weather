//
//  WeatherViewController.swift
//  Weather
//
//  Created by Dmitrii Tikhomirov on 2/21/23.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    //MARK: - Create enum for all sizes that we need
    
    private enum ViewMetrics {
        static let spacing: CGFloat = 16.0
        static let textSize: CGFloat = 24.0
        static let buttonSize: CGFloat = 32.0
        static let padding: CGFloat = 32.0
        static let cityLabelSize: CGFloat = 40.0
        static let labelSize: CGFloat = 64.0
        static let imageWeatherSize: CGFloat = 128.0
    }
    //
    private let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    private let localButton = UIButton.customButton(title: "location.circle.fill", size: ViewMetrics.buttonSize)
    private let searchTextField = UITextField.customTextField(title: "Search some city ...", size: ViewMetrics.textSize, weight: .bold)
    private let searchButton = UIButton.customButton(title: "magnifyingglass", size: ViewMetrics.buttonSize)
    private let conditionImageView = UIImageView()
    private let temperatureLabel = UILabel.customLabel(title: "27.1", size: ViewMetrics.labelSize, weight: .bold)
    private let celsiusLabel = UILabel.customLabel(title: "ºC", size: ViewMetrics.labelSize, weight: .regular)
    private let cityLabel = UILabel.customLabel(title: "San Francisco", size: ViewMetrics.cityLabelSize, weight: .bold)
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundImage()
        configureTopHorizontalStack()
        localButton.addTarget(self, action: #selector(location), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(search), for: .touchUpInside)
        configureConditionImageView()
        configureGradusCelsiusStack()
        confugureCityLabel()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
    }
    
    //MARK: - Setup backgroundImage
    
    private func configureBackgroundImage() {
        //Create a UIImageView with the desired image
        backgroundImage.image = UIImage(named: "background")
        //Set the content mode to scale aspect fill
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        //Add the image view as a subview of the main view
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
    }
    
    //MARK: - Create & setup topHorizontalStack
    
    private lazy var topHorizontalStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [localButton, searchTextField, searchButton])
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    //MARK: - Add constraints to topHorizontalStack
    
    private func configureTopHorizontalStack() {
        view.addSubview(topHorizontalStack)
        let guide = view.safeAreaLayoutGuide
        topHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topHorizontalStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: ViewMetrics.spacing),
            topHorizontalStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: ViewMetrics.spacing),
            topHorizontalStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -ViewMetrics.spacing)
        ])
    }
    
    //MARK: - Create, setup, add constraints to conditionImageView
    
    private func configureConditionImageView() {
        conditionImageView.image = UIImage(systemName: "sun.max")
        conditionImageView.contentMode = .scaleAspectFill
        conditionImageView.tintColor = .systemBackground
        view.addSubview(conditionImageView)
        let guide = view.safeAreaLayoutGuide
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            conditionImageView.topAnchor.constraint(equalTo: topHorizontalStack.bottomAnchor, constant: ViewMetrics.padding),
            conditionImageView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -ViewMetrics.spacing),
            conditionImageView.widthAnchor.constraint(equalToConstant: ViewMetrics.imageWeatherSize),
            conditionImageView.heightAnchor.constraint(equalToConstant: ViewMetrics.imageWeatherSize)
        ])
    }
    
    //MARK: - Create & setup gradusCelsiusStack
    
    private lazy var gradusCelsiusStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [temperatureLabel, celsiusLabel])
        stackView.distribution = .equalCentering
        stackView.axis = .horizontal
        stackView.alignment = .trailing
        return stackView
    }()
    
    //MARK: - Add constraints to gradusCelsiusStack
    
    private func configureGradusCelsiusStack() {
        view.addSubview(gradusCelsiusStack)
        let guide = view.safeAreaLayoutGuide
        gradusCelsiusStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradusCelsiusStack.topAnchor.constraint(equalTo: conditionImageView.bottomAnchor, constant: ViewMetrics.padding),
            gradusCelsiusStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -ViewMetrics.spacing),
        ])
    }
    
    private func confugureCityLabel() {
        view.addSubview(cityLabel)
        let guide = view.safeAreaLayoutGuide
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: gradusCelsiusStack.bottomAnchor, constant: ViewMetrics.padding),
            cityLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -ViewMetrics.spacing),
        ])
    }
    
    @objc func location() {
        locationManager.requestLocation()
    }

}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @objc func search() {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.temperatureLabel.text = weather.temperatureString
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension  WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - Extension to UIButton to create custom buttons

private extension UIButton {
    static func customButton(title: String, size: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: size, weight: .regular, scale: .default)
        button.setImage(UIImage(systemName: title, withConfiguration: largeConfig), for: .normal)
        button.tintColor = .systemBackground
        //let action = #selector(WeatherViewController.location)
        //button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

//MARK: - Extension to UITextField to create custom field

private extension UITextField {
    static func customTextField(title: String, size: CGFloat, weight: UIFont.Weight) -> UITextField {
        let textField = UITextField()
        textField.placeholder = title
        textField.font = .systemFont(ofSize: size, weight: weight)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemFill
        textField.textColor = .systemBackground
        return textField
    }
}

//MARK: - Extension to UILabel to create custom label

private extension UILabel {
    static func customLabel(title: String, size: CGFloat, weight: UIFont.Weight) -> UILabel {
        let customLabel = UILabel()
        customLabel.text = title
        customLabel.font = .systemFont(ofSize: size, weight: weight)
        customLabel.textColor = .systemBackground
        return customLabel
    }
}
