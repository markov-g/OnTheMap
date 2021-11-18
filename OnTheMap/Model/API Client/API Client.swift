//
//  API Client.swift
//  OnTheMap
//
//  Created by Georgi Markov on 10/21/21.
//

import Foundation


class APIClient {    
    static let UDACITY_USERNAME = fetchSecretsPlist()["UdemyUsername"]
    static let UDACITY_PASSWORD = fetchSecretsPlist()["UdemyPassword"]
    
    
    struct Auth {
        static var sessionID: String? = nil
        static var key: String = ""
        static var username: String = ""
        static var firstName: String = ""
        static var lastName: String = ""
        static var objectId: String = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        
        case udacitySignUp
        case getSession
        case getStudentLocation(limit: Int)
        case addLocation
        case updateLocation
        case getLoggedInUserProfile
        
        var stringValue: String {
            switch self {
                case .udacitySignUp:
                    return "https://auth.udacity.com/sign-up"
                case .getSession:
                    return Endpoints.base + "/session"
                case .getStudentLocation(let limit):
                    return Endpoints.base + "/StudentLocation?limit=\(limit)&order=-updatedAt"
                case .addLocation:
                    return Endpoints.base + "/StudentLocation"
                case .updateLocation:
                    return Endpoints.base + "/StudentLocation/" + Auth.objectId
                case .getLoggedInUserProfile:
                    return Endpoints.base + "/users/" + Auth.key
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping(ResponseType?, Error?)->Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func taskForPOSTRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: String, completion: @escaping(ResponseType?, Error?)->Void) -> Void {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)


        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
                        
            guard let data = data else { // If no data returned, handle error ...
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                let responseObj = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObj, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        .resume()
    }

    
    class func getSession(username: String, passwd: String, completion: @escaping (Bool, Error?) -> Void) -> Void {
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(passwd)\"}}"
        taskForPOSTRequest(url: Endpoints.getSession.url, responseType: LoginSessionResponse.self, body: body) { response, error in
            if let response = response {
                Auth.sessionID = response.session.id
                Auth.key = response.account.key
                Auth.username = username
                getLoggedInUserProfile(completion: { (success, error) in
                    if success {
                        print("Logged in user's profile fetched.")
                    }
                })
                completion(true, nil)
            }
            else {
                completion(false, error)
            }
        }
    }
   
    //TODO: FIXME
    class func getLoggedInUserProfile(completion: @escaping (Bool, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.getLoggedInUserProfile.url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                print("Failed to get user's profile.")
                completion(false, error)
            }
            guard let data = data else { // If no data returned, handle error ...
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let range = 5..<data.count
                let newData = data.subdata(in: range)
                let responseObj = try decoder.decode(UserProfile.self, from: newData)
                Auth.firstName = responseObj.firstName
                Auth.lastName = responseObj.lastName
                Auth.key = responseObj.key
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }.resume()
    }
    
    class func getStudentLocations(limit: Int, completion: @escaping ([StudentInformation]?, Error?) -> Void) -> Void {
        taskForGETRequest(url: Endpoints.getStudentLocation(limit: limit).url, response: StudentLocation.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            }
            else {
                completion([], error)
            }
        }
    }
    
    class func addNewStudentLocation(student: StudentInformation, completion: @escaping (Bool, Error?) -> Void) -> Void {
        let body = "{\"uniqueKey\": \"\(student.uniqueKey ?? "")\", \"firstName\": \"\(Auth.firstName)\", \"lastName\": \"\(Auth.lastName)\",\"mapString\": \"\(student.mapString ?? "")\", \"mediaURL\": \"\(student.mediaURL ?? "")\",\"latitude\": \(student.latitude ?? 0.0), \"longitude\": \(student.longitude ?? 0.0)}"
        var request = URLRequest(url: Endpoints.addLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, err in
            if err != nil { // Handle error…
                DispatchQueue.main.async {
                    completion(false, err)
                }
            }
            
            guard let data = data else { // If no data returned, handle error ...
                DispatchQueue.main.async {
                    completion(false, err)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObj = try decoder.decode(PostLocationResponse.self, from: data)
                Auth.objectId = responseObj.objectId
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, err)
                }
            }
        }.resume()
        
    }
    
    class func updateStudentLocation(student: StudentInformation, completion: @escaping (Bool, Error?) -> Void) -> Void {
        var request = URLRequest(url: Endpoints.updateLocation.url)
        let body = "{\"uniqueKey\": \"\(student.uniqueKey ?? "")\", \"firstName\": \"\(Auth.firstName)\", \"lastName\": \"\(Auth.lastName)\",\"mapString\": \"\(student.mapString ?? "")\", \"mediaURL\": \"\(student.mediaURL ?? "")\",\"latitude\": \(student.latitude ?? 0.0), \"longitude\": \(student.longitude ?? 0.0)}"
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, err in
            if err != nil { // Handle error…
                DispatchQueue.main.async {
                    completion(false, err)
                }
            }
            
            guard let data = data else { // If no data returned, handle error ...
                DispatchQueue.main.async {
                    completion(false, err)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObj = try decoder.decode(UpdateLocationResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, err)
                }
            }
        }.resume()
    }
    
    class func deleteSessionAndLogout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.getSession.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error logging out.")
                return
            }
            let range = 5..<data!.count
            let newData = data?.subdata(in: range)
            print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionID = ""
            completion()
        }.resume()
    }
}
