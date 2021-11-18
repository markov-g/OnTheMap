//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Georgi Markov on 10/25/21.
//

import UIKit

class ListViewController: UIViewController {
    @IBOutlet weak var locationListTableView: UITableView!
    
    @IBAction func refreshBtnTapped(_ sender: UIBarButtonItem) {
        locationListTableView.reloadData()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationListTableView.delegate = self
        locationListTableView.dataSource = self
        locationListTableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        // Do any additional setup after loading the view.
        locationListTableView.reloadData()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.studentInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentInfo = StudentModel.studentInfos[indexPath.row]
        
        let cell = locationListTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageCell
        cell.nameLbl.text = "\(studentInfo.firstName) \(studentInfo.lastName)"
        if let mediaURL = studentInfo.mediaURL {
            cell.mediaURLLbl.text = mediaURL
        }
        
        return cell
    }
}
