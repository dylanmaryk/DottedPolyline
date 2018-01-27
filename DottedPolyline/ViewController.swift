//
//  ViewController.swift
//  DottedPolyline
//
//  Created by Dylan Maryk on 27/01/2018.
//  Copyright © 2018 dylanmaryk. All rights reserved.
//

import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private let polyline = GMSPolyline(path: GMSPath(fromEncodedPath: "{dq_IowzpAzkAbhF"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        set(polyline: polyline, on: mapView)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        set(polyline: polyline, on: mapView)
    }
    
    private func set(polyline: GMSPolyline, on mapView: GMSMapView) {
        guard let path = polyline.path else {
            return
        }
        mapView.clear()
        let intervalDistanceIncrement: CGFloat = 10
        let circleRadiusScale = 1 / mapView.projection.points(forMeters: 1, at: mapView.camera.target)
        var previousCircle: GMSCircle?
        for coordinateIndex in 0 ..< path.count() - 1 {
            let startCoordinate = path.coordinate(at: coordinateIndex)
            let endCoordinate = path.coordinate(at: coordinateIndex + 1)
            let startLocation = CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
            let endLocation = CLLocation(latitude: endCoordinate.latitude, longitude: endCoordinate.longitude)
            let pathDistance = endLocation.distance(from: startLocation)
            let intervalLatIncrement = (endLocation.coordinate.latitude - startLocation.coordinate.latitude) / pathDistance
            let intervalLngIncrement = (endLocation.coordinate.longitude - startLocation.coordinate.longitude) / pathDistance
            for intervalDistance in 0 ..< Int(pathDistance) {
                let intervalLat = startLocation.coordinate.latitude + (intervalLatIncrement * Double(intervalDistance))
                let intervalLng = startLocation.coordinate.longitude + (intervalLngIncrement * Double(intervalDistance))
                let circleCoordinate = CLLocationCoordinate2D(latitude: intervalLat, longitude: intervalLng)
                if let previousCircle = previousCircle {
                    let circleLocation = CLLocation(latitude: circleCoordinate.latitude,
                                                    longitude: circleCoordinate.longitude)
                    let previousCircleLocation = CLLocation(latitude: previousCircle.position.latitude,
                                                            longitude: previousCircle.position.longitude)
                    if mapView.projection.points(forMeters: circleLocation.distance(from: previousCircleLocation),
                                                 at: mapView.camera.target) < intervalDistanceIncrement {
                        continue
                    }
                }
                let circleRadius = 3 * CLLocationDistance(circleRadiusScale)
                let circle = GMSCircle(position: circleCoordinate, radius: circleRadius)
                circle.map = mapView
                previousCircle = circle
            }
        }
    }
    
}
