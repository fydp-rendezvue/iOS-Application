//
//  ViewController.swift
//  fydp-test
//
//  Created by Dong Hyuk Chang on 2019-07-15.
//  Copyright © 2019 Dong Hyuk Chang. All rights reserved.
//

import ARCL
import CoreLocation

import UIKit

class ViewController: UIViewController {

    var sceneLocationView = SceneLocationView()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.showAxesNode = true
        sceneLocationView.showFeaturePoints = true
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        
        locationManager.requestWhenInUseAuthorization()
        
        addSceneModels()
        getSharedMarkers()
        
        let button = UIButton(frame: CGRect(x: view.frame.midX, y: UIScreen.main.bounds.height * 0.85, width: 100, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Add", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        sceneLocationView.addSubview(button)
        
        view.addSubview(sceneLocationView)
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
        let image = UIImage(named: "pin")!
        let annotationNode = LocationAnnotationNode(location: nil, image: image)
        annotationNode.scaleRelativeToDistance = false
        
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
        postSharedMarker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        sceneLocationView.run()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        guard let touch = touches.first,
//            let view = touch.view else { return }
//
//        let image = UIImage(named: "pin")!
//        let annotationNode = LocationAnnotationNode(location: nil, image: image)
//        annotationNode.scaleRelativeToDistance = false
//
//        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
//        postSharedMarker()
//    }
    
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }
    }
    
    func postSharedMarker(){
        let urlString = "https://a59db6b6.ngrok.io/users/1/rooms/1/marker"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Double] = [
            "longitude": sceneLocationView.sceneLocationManager.currentLocation?.coordinate.longitude ?? 0.0,
            "latitude": sceneLocationView.sceneLocationManager.currentLocation?.coordinate.latitude ?? 0.0,
            "altitude": sceneLocationView.sceneLocationManager.currentLocation?.altitude ?? 0.0
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject:  parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
        }
        
        task.resume()
        
    }
    
    func getSharedMarkers() {
        let urlString = "https://a59db6b6.ngrok.io/users/1/rooms/1/markers"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
            let results = json["results"] as! [[String:Any]]
            
            results.forEach{
                let latitude = CLLocationDegrees(exactly: $0["latitude"] as! NSNumber)
                let longitude = CLLocationDegrees(exactly: $0["longitude"] as! NSNumber)
                let altitude = CLLocationDegrees(exactly: $0["altitude"] as! NSNumber)
                let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                let location = CLLocation(coordinate: coordinate, altitude: altitude!)
                let image = UIImage(named:"pin")!
                
                let annotationNode = LocationAnnotationNode(location: location, image: image)
                annotationNode.scaleRelativeToDistance = true
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
        }
        
        task.resume()
    }
        

}

