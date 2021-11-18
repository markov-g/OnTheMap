//
//  UserProfile.swift
//  OnTheMap
//
//  Created by Georgi Markov on 11/16/21.
//

import Foundation


struct User: Codable {
    let user: UserProfile
}

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let key: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case key = "key"
        
    }
    
}
