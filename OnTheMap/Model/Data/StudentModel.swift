//
//  StudentModel.swift
//  OnTheMap
//
//  Created by Georgi Markov on 11/1/21.
//

import Foundation

struct StudentModel {
    static var studentInfos = [StudentInformation]()
    
    static func addNewStudent(info: StudentInformation) {
        studentInfos.append(info)        
    }
}
