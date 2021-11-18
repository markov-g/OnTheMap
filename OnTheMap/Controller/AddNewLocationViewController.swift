//
//  AddNewLocationViewController.swift
//  OnTheMap
//
//  Created by Georgi Markov on 11/3/21.
//

import UIKit
import CoreLocation

class AddNewLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationBtn: UIButton!
    @IBOutlet weak var cancelBarBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
    }
    
    @IBAction func findLocationBtnTapped(_ sender: UIButton) {
        guard let locationText = locationTextField.text, !locationText.isEmpty else {
            showFailure(title: "Error", message: "Please provide a location")
            return
        }
        
        guard let linkText = urlTextField.text, !linkText.isEmpty, checkLinkValidity(urlTextField.text!) else {
            showFailure(title: "Error", message: "Please provide valid URL!")
            return
        }
        
        // geocode location
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationText) { placemarks, error in
            if let error = error {
                self.showFailure(title: "Location Not Found", message: error.localizedDescription)
            }
            guard let placemark = placemarks?.first, let location = placemark.location else { return }
            
            self.addNewLocation(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
    }
    
    func checkLinkValidity(_ linkText: String) -> Bool {
        guard let url = URL(string: urlTextField.text!) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func addNewLocation(lat: CLLocationDegrees, long: CLLocationDegrees) {
        let newStudent = StudentInformation(createdAt: nil, firstName: APIClient.Auth.firstName, lastName: APIClient.Auth.lastName, latitude: lat, longitude: long, mapString: locationTextField.text!, mediaURL: urlTextField.text!, objectId: APIClient.Auth.objectId, uniqueKey: APIClient.Auth.key, updatedAt: Date.now.formatted(date: .abbreviated, time: .shortened).description)        
        
        // Transition to DetailView
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "AddNewLocationMapViewController")as! AddNewLocationMapViewController
        resultVC.student = newStudent
        self.present(resultVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelBarBtnTapped(_ sender: UIBarButtonItem) {
    }
}
