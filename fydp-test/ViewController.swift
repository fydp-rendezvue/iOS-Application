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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // let coordinate = CLLocationCoordinate2D(latitude: 43.472394, longitude: -80.534148)
        // let location = CLLocation(coordinate: coordinate, altitude: 300)
        
        addSceneModels()
        view.addSubview(sceneLocationView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        print("run")
        sceneLocationView.run()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first,
            let view = touch.view else { return }

        let image = UIImage(named: "pin")!
        let annotationNode = LocationAnnotationNode(location: nil, image: image)
        annotationNode.scaleRelativeToDistance = false
        // annotationNode.scalingScheme = .normal
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)

        let urlString = "https://a646ae19.ngrok.io/users/1/rooms/1/marker"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Double] = [
            "longitude": sceneLocationView.sceneLocationManager.currentLocation?.coordinate.longitude ?? 0.0,
            "latitude": sceneLocationView.sceneLocationManager.currentLocation?.coordinate.latitude ?? 0.0
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject:  parameters, options: []) else { return }
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
        }
        
        task.resume()
        
    }
    
    func addSceneModels() {
        // 1. Don't try to add the models to the scene until we have a current location
        guard sceneLocationView.sceneLocationManager.currentLocation != nil else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addSceneModels()
            }
            return
        }
        
//        let image = UIImage(named: "pin")!
//        // let currentLocation = sceneLocationView.sceneLocationManager.currentLocation
//
//        let annotationNode = LocationAnnotationNode(location: nil, image: image)
//        annotationNode.scaleRelativeToDistance = false
//        annotationNode.scalingScheme = .normal
//
//        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
    }

}

