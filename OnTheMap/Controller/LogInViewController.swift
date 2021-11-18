//
//  ViewController.swift
//  OnTheMap
//
//  Created by Georgi Markov on 10/21/21.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwdTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginFacebookButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = ""
        passwdTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }        

    @IBAction func loginTapped(_ sender: UIButton) {
        setLoggingIn(true)
        let username = emailTextField.text ?? ""
        let passwd = passwdTextField.text ?? ""
        APIClient.getSession(username: username, passwd: passwd, completion: handleSessionResponse(success:err:))
    }
    
    @IBAction func signUpBtnTapped(_ sender: UIButton) {
        UIApplication.shared.open(APIClient.Endpoints.udacitySignUp.url, options: [:], completionHandler: nil)
    }
    
    func handleSessionResponse(success: Bool, err: Error?) {
        setLoggingIn(false)
        if success {
            performSegue(withIdentifier: "login", sender: self)
        } else {
            showFailure(title: "Login Failed", message: err?.localizedDescription ?? "Something went wrong, please check your entries!")
        }
    }
    
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwdTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
        loginFacebookButton.isEnabled = !loggingIn
    }
}

