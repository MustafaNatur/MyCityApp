//
//  MapViewController.swift
//  MyCityApp
//
//  Created by Мустафа Натур on 24.02.2023.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAdress(_ address: String?)
}

class MapViewController: UIViewController {

    var delegateMap: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentificator = "identificator"
    let locationManager = CLLocationManager()
    let regionInMeters = 1000.0
    var incomeSegueIdentier  = ""
    var placeCoordinate:CLLocationCoordinate2D?
    
    @IBOutlet weak var buildDirectionButton: UIButton!
    @IBOutlet weak var mapPinImageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var placeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        placeLabel.text = ""
        buildDirectionButton.isHidden = true
        checkLocationServices()

    }
    @IBAction func cancleButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func applyButtonPressed(_ sender: Any) {
        delegateMap?.getAdress(placeLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func centerOnUserLocation(_ sender: Any) {
        showUserLocation()
    }
    
    @IBAction func buildDirectionButtonPressed(_ sender: Any) {
        getDiretions()
    }
    
    func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getDiretions() {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Oops...", message: "Current location is not found")
            return
        }
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not avaiable")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места \(distance)")
                print("Время в пути: \(timeInterval) сек")
            }
        }
    }
    
    private func createDirectionRequest(from coordinate:CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
            self.placeCoordinate = placemarkLocation.coordinate
            
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
            if incomeSegueIdentier == "showPlace" {
                mapPinImageView.isHidden = true
                applyButton.isHidden = true
                placeLabel.isHidden = true
                buildDirectionButton.isHidden = false
                setupPlacemark()
            } else {
                showUserLocation()
            }
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor =  .black
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAauthorization()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else {return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            self.placeLabel.text = "\(streetName ?? ""), \(buildNumber ?? "")"
        }
    }
}
