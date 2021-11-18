//
//  LoginSessionResponse.swift
//  OnTheMap
//
//  Created by Georgi Markov on 10/28/21.
//

import Foundation
import AudioToolbox

struct LoginSessionResponse: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}
