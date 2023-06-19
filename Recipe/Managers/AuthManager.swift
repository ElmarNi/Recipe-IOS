//
//  AuthManager.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 13.06.23.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let baseUrl = "https://localhost:7289/"
    }
    
    enum HttpMethod: String {
        case GET
        case POST
    }
    
    struct ApiError: LocalizedError {
        let description: String
        init(_ description: String) {
            self.description = description
        }
    }
    
    public var isSignedIn: Bool = {
        guard let isSignedIn = UserDefaults.standard.value(forKey: "isSignedIn") as? Bool else { return false }
        return isSignedIn
    }()
    
    public func signIn(username: String, password: String, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Account/Login"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = ["userName": username, "password": password]
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let response = result as? [String: Any],
                       let code = response["code"] as? Int,
                       let userId = response["userId"] as? String,
                       code == 200 {
                        completion(true)
                        UserDefaults.standard.set(true, forKey: "isSignedIn")
                        UserDefaults.standard.set(userId, forKey: "userId")
                    }
                    else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                }
                
            }.resume()
        }
    }
    
    public func register(with model: User, sessionDelegate: URLSessionDelegate, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Account/Register"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [
                "firstName": model.firstname,
                "lastName": model.lastname,
                "userName": model.userName,
                "password": model.password,
                "email": model.email
            ]
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError("Something went wrong")))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RegisterResponse.self, from: data)
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                    UserDefaults.standard.set(result.userId, forKey: "userId")
                    completion(.success(result))
                }
                catch {
                    completion(.failure(ApiError("Something went wrong")))
                }

            }.resume()
        }
    }
    
    public func getUserData(with id: String, sessionDelegate: URLSessionDelegate, completion: @escaping (Result<User, Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Account/GetUser"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [ "id": id ]
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError("Something went wrong")))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(User.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(ApiError("Something went wrong")))
                }

            }.resume()
        }
    }
    
    private func createRequest(with url: URL?, type: HttpMethod, completion: @escaping (URLRequest) -> Void) {
        guard let url = url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.timeoutInterval = 50
        completion(request)
    }
    
}
