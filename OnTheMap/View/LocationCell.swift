//
//  LocationCell.swift
//  OnTheMap
//
//  Created by Georgi Markov on 11/5/21.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var pinImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var mediaURLLbl: UILabel!
    @IBOutlet weak var cell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tap)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func handleCellTap(_ sender: UITapGestureRecognizer) {
        let app = UIApplication.shared
        if let mediaURL = mediaURLLbl.text {
            let url = URL(string: mediaURL)!
            app.open(url, options: [:], completionHandler: nil)
        }
    }
}
