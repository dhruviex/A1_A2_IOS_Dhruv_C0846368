//
//  ViewController.swift
//  A1_A2_Dhruv_C0846368
//
//  Created by Dhruv Bakshi on 2022-05-24.
//

import MapKit
import UIKit
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate , UITextFieldDelegate,UIGestureRecognizerDelegate,MKMapViewDelegate{
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var textField_Address: UITextField!
    
    
    let manager = CLLocationManager()
    var myGeoCoder = CLGeocoder()

    override func viewDidLoad() {
    super.viewDidLoad()
        // Do any additional setup after loading the view.

        myMap.showsUserLocation = true
        myMap.isZoomEnabled = true
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest

        manager.startUpdatingLocation()
        // User Current Location
        let coordinates = CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0.0, longitude: manager.location?.coordinate.longitude ?? 0.0)

        let span = MKCoordinateSpan (latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        myMap.setRegion(region, animated: true)
        
        let myPin = MKPointAnnotation()
        
        myPin.coordinate = coordinates
        myPin.title = " Hey There!"
        myPin.subtitle = "I'm Here!"
        myMap.addAnnotation(myPin)
        
        textField_Address.delegate = self
        
        
        let oLng = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion(gestureRecognizer:)))
        
        myMap.addGestureRecognizer(oLng)
        
        
        addDoubleTap()
        
        
        myMap.delegate = self
}

    @IBAction func buttonDirection(_ sender: Any) {
        myGeoCoder.geocodeAddressString(textField_Address.text ?? ""){
            (placemarks,error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    func processResponse(withPlacemarks placemarks:[CLPlacemark]?,error: Error?){
        if let error = error{
            print("error Fetching Coordinates (\(error)")
        }else {
            var location :CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0{
                location = placemarks.first?.location
            }
            
            if let location = location{
                
                let coordinate = location.coordinate
                
                
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0.0, longitude: manager.location?.coordinate.longitude ?? 0.0)))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)))
                request.transportType = .any
                request.requestsAlternateRoutes = true
                                           
                let directions = MKDirections(request: request)
                directions.calculate{response , error in
                guard let directionsresponse = response else {return}
            
                    for route in directionsresponse.routes{
                        self.myMap.addOverlay(route.polyline)
                        self.myMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                                           
            }
                
                let myPin = MKPointAnnotation()
                
                myPin.coordinate = coordinate
                
                myPin.title = textField_Address.text
                myMap.addAnnotation(myPin)
                
        }
        
    }
    }
    
    
    func mapView( mapView:MKMapView , rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolygonRenderer(overlay : overlay as! MKPolyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        return renderer
    }
    
    /*
@objc  func locationManager(manager: CLLocationManager ,didupdateLocations locations: [CLLocation]) {
        if let userLocations = locations.last  {
            
            manager.stopUpdatingLocation()
            
            let coordinates = CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0.0, longitude: manager.location?.coordinate.longitude ?? 0.0)

            let span = MKCoordinateSpan (latitudeDelta: 0.5, longitudeDelta: 0.5)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            myMap.setRegion(region, animated: true)
            
        }
        
    } */
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedAlways:
            return
        case .authorizedWhenInUse:
            return
        case .denied:
            return
        case .restricted:
            manager.requestWhenInUseAuthorization()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            manager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    //Double Tap to Drop A pin
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        myMap.addGestureRecognizer(doubleTap)
        
    }
    // Triple Tap to REmove the Drop PIN
    func addTripleTap() {
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(removePin))
        tripleTap.numberOfTapsRequired = 3
        myMap.addGestureRecognizer(tripleTap)
        
    }
    
    // Object Fuctions
    @objc func dropPin(sender: UITapGestureRecognizer) {
        // add annotation
        let touchPoint = sender.location(in: myMap)
        let coordinate = myMap.convert(touchPoint, toCoordinateFrom: myMap)
        let annotation = MKPointAnnotation()
        annotation.title = "Drop Pin"
        annotation.coordinate = coordinate
        myMap.addAnnotation(annotation)
    }
    
    @objc func addLongPressAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: myMap)
        let coordinate = myMap.convert(touchPoint, toCoordinateFrom: myMap)
        
        // add annotation for the coordinatet
        let annotation = MKPointAnnotation()
        annotation.title = "Drop Point"
        annotation.coordinate = coordinate
        myMap.addAnnotation(annotation)
    }
    
    @objc func removePin() {
        for annotation in myMap.annotations {
            myMap.removeAnnotation(annotation)
        }
    }

//

    // Annotation Section
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "First Marker A")
        annotationView.markerTintColor = UIColor.red
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return annotationView
    }
        /*
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "Current Location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "A")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "Second Location":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "B")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
            return annotationView
        case "Third Location":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "C")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            return annotationView
        default:
            return nil
        }
    } */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.green
            rendrer.fillColor = UIColor.red.withAlphaComponent(1.0)
            rendrer.lineWidth = 3
            return rendrer
        }
        else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.red
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
    }


