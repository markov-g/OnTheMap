//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Georgi Markov on 10/25/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    let numberOfStudentLocations: Int = 150
    // We will create an MKPointAnnotation for each dictionary in "locations". The
    // point annotations will be stored in this array, and then provided to the map view.
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        APIClient.getStudentLocations(limit: numberOfStudentLocations, completion: handleStudentLocationResponse(studentInfos:error:))
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        addAnnotations()
    }
    
    @IBAction func logoutBtnTapped(_ sender: UIBarButtonItem) {
        APIClient.deleteSessionAndLogout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addNewLocationBtnTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newLocationVC = storyboard.instantiateViewController(withIdentifier: "AddNewLocationViewController") as! AddNewLocationViewController
        newLocationVC.modalPresentationStyle = .fullScreen
        newLocationVC.modalTransitionStyle = .crossDissolve
        self.present(newLocationVC, animated: true, completion: nil)
    }
    
    func handleStudentLocationResponse(studentInfos: [StudentInformation]?, error: Error?) {
        if error != nil {
            let alertVC = UIAlertController(title: "Loading Student Information failed", message: "something went wrong trying to load Student Information", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            show(alertVC, sender: nil)
        }
        
        if let studentInfos = studentInfos {
            StudentModel.studentInfos = studentInfos
            debugPrint("Requested \(numberOfStudentLocations) locations from API and downloaded \(StudentModel.studentInfos.count) student locations ...")
            DispatchQueue.main.async {
                self.addAnnotations()
            }
        }
    }
    
    func addAnnotations() -> Void {
        for student in StudentModel.studentInfos {
            let annotation = obtainAnnotation(for: student)
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
            mapView.addAnnotation(annotation)
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}



