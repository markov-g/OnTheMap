//
//  UIViewController+Extensions.swift
//  OnTheMap
//
//  Created by Georgi Markov on 11/8/21.
//

import UIKit
import CoreLocation
import MapKit

extension UIViewController {
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    func obtainAnnotation(for student: StudentInformation) -> MKPointAnnotation {
        // Notice that the float values are being used to create CLLocationDegree values.
        // This is a version of the Double type.
        let lat = CLLocationDegrees(student.latitude!)
        let long = CLLocationDegrees(student.longitude!)
        
            // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let first = student.firstName
        let last = student.lastName
        let mediaURL = student.mediaURL
        
            // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(first) \(last)"
        annotation.subtitle = mediaURL
        
        return annotation
    }
}
