//
//  APICaller.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 01.06.23.
//

import Foundation
import UIKit



final class ApiCaller {
    
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
    
    static let shared = ApiCaller()
    
    public func getCategories(sessionDelegate: URLSessionDelegate, completion: @escaping (Result<[Category], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Category/GetCategories"), type: .GET) { request in
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError("Failed to get data")))
                    return
                }
                do {
                    let result = try JSONDecoder().decode([Category].self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getPopularRecipes(sessionDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetPopularRecipes"), type: .GET) { request in
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError("Failed to get data")))
                    return
                }
                do {
                    let result = try JSONDecoder().decode([Recipe].self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getRecommendedRecipes(sessionDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/RecommendedRecipes"), type: .GET) { request in
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(ApiError("Failed to get data")))
                    return
                }
                do {
                    let result = try JSONDecoder().decode([Recipe].self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
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
