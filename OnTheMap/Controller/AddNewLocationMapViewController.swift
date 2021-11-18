//
//  AddNewLocationMapViewController.swift
//  OnTheMap
//
//  Created by Georgi Markov on 11/4/21.
//

import UIKit
import MapKit

class AddNewLocationMapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var student: StudentInformation!
    var annotation = MKPointAnnotation()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        annotation = obtainAnnotation(for: student)
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @IBAction func finishBtnTapped(_ sender: UIButton) {
        if APIClient.Auth.objectId == "" {
            APIClient.addNewStudentLocation(student: student) { success, err in
                if success {
                    DispatchQueue.main.async {
                        //self.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "finish", sender: self)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showFailure(title: "Error publishing location", message: err?.localizedDescription ?? "")
                    }
                }
            }
        } else {
            APIClient.updateStudentLocation(student: student) { success, err in
                if success {
                    DispatchQueue.main.async {
                        //self.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "finish", sender: self)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showFailure(title: "Error updating location", message: err?.localizedDescription ?? "")
                    }
                }
            }
        }
    }
}


extension AddNewLocationMapViewController: MKMapViewDelegate {
    
}
