//
//  LocationManager.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 21.10.2023.
//

import Foundation
import CoreLocation
import RxSwift

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private let locationSubject = BehaviorSubject<CLLocationCoordinate2D?>(value: nil)
        
        var currentLocation: Observable<CLLocationCoordinate2D> {
            return locationSubject
                .compactMap { $0 }
                .asObservable()
        }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        let status = CLLocationManager.authorizationStatus()
        handleAuthorization(status: status)
    }
    
    func handleAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorization(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first?.coordinate {
            locationSubject.onNext(location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationSubject.onError(error)
    }
    
    func coordinates(for address: String) -> Observable<CLLocationCoordinate2D> {
        Observable.create { observer in
            CLGeocoder().geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                if let coordinates = placemarks?.first?.location?.coordinate {
                    observer.onNext(coordinates)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func distance(to address: String) -> Observable<Double> {
        Observable.combineLatest(
            currentLocation,
            coordinates(for: address)
        ).map { myCoordinates, targetCoordinates in
            let myLocation = CLLocation(latitude: myCoordinates.latitude, longitude: myCoordinates.longitude)
            let targetLocation = CLLocation(latitude: targetCoordinates.latitude, longitude: targetCoordinates.longitude)
            let distanceInMeters = myLocation.distance(from: targetLocation)
            return distanceInMeters
        }
    }
    
}

