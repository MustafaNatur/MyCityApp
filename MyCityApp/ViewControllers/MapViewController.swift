//
//  MapViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 24.02.2023.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var place:Place!
    let annotationIdentificator = "identificator"
    let locationManager = CLLocationManager()
    let regionInMeters = 1000.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlacemark()
        mapView.delegate = self
        
        checkLocationServices()

    }
    @IBAction func cancleButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func centerOnUserLocation(_ sender: Any) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupPlacemark() {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
             setupLocationManager()
             checkLocationAauthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(
                    title: "Location Services are Disabled",
                    message: "To enable it go: Settings -> Privacy -> Location Services and On"
                )
            }
        }
    }
    
    private func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAauthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case")
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    // для того что бы правильно отобразить аннотацию мы подписываем наш класс на протокол MKMapViewDdelegate
    
    // для ототображения аннтоции реализуем метод
    
    // перед тем как изменить вид аннотации нужно убедиться что мы не предоставляем аннотацию к местоположению самого себя
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil} // проверка на то что мы не самого себя отображаем
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentificator) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentificator)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width:50, height: 50))
            imageView.layer.cornerRadius = 15
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.leftCalloutAccessoryView  = imageView
        }

        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAauthorization()
    }
}
