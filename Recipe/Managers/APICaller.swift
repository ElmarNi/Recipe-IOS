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
        createRequest(with: URL(string: Constants.baseUrl + "Category/GetAll"), type: .GET) { request in
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
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetRecommendedRecipes"), type: .GET) { request in
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
    
    public func searchRecipe(with query: String, sessionDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        let urlString = Constants.baseUrl + "Recipe/SearchRecipes?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        createRequest(with: URL(string: urlString), type: .GET) { request in
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
    
    public func getRecipe(with id: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Result<Recipe, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetRecipe?recipeId=\(id)"), type: .GET) { request in
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
                    let result = try JSONDecoder().decode(Recipe.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getRecipesByCategoryId(categoryId: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetRecipesByCategoryId?id=\(categoryId)"), type: .GET) { request in
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
    
    public func getBookmarks(userId: String, sessinDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetFavoriteRecipesByUserId?userId=\(userId)"), type: .GET) { request in
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessinDelegate,
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
    
    public func getUserRecipes(userId: String, sessinDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetRecipesByUserId?userId=\(userId)"), type: .GET) { request in
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessinDelegate,
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
    
    public func addBookmark(userId: String, recipeId: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/AddFavorite"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [
                "recipeId": recipeId,
                "userId": userId
            ] as [String : Any]
            
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, response, error in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    completion(false)
                    return
                }
                
                completion(true)

            }.resume()
        }
    }
    
    public func removeBookmark(userId: String, recipeId: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/RemoveFavorite"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [
                "recipeId": recipeId,
                "userId": userId
            ] as [String : Any]
            
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, response, error in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    completion(false)
                    return
                }
                
                completion(true)

            }.resume()
        }
    }
    
    public func removeRecipe(recipeId: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/RemoveRecipe?recipeId=\(recipeId)"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [
                "recipeId": recipeId
            ] as [String : Any]
            
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, response, error in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    completion(false)
                    
                    return
                }
                
                completion(true)

            }.resume()
        }
    }
    
    public func getLikes(userId: String, sessinDelegate: URLSessionDelegate, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/GetLikedRecipesByUserId?userId=\(userId)"), type: .GET) { request in
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessinDelegate,
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
    
    public func like(userId: String, recipeId: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/Like"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [
                "recipeId": recipeId,
                "userId": userId
            ] as [String : Any]
            
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, response, error in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    completion(false)
                    return
                }
                
                completion(true)

            }.resume()
        }
    }
    
    public func unLike(userId: String, recipeId: Int, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/UnLike"), type: .POST) { baseRequest in
            
            var request = baseRequest
            let json = [
                "recipeId": recipeId,
                "userId": userId
            ] as [String : Any]
            
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, response, error in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    completion(false)
                    return
                }
                
                completion(true)

            }.resume()
        }
    }
    
    public func addRecipe(recipe: Recipe, sessionDelegate: URLSessionDelegate, completion: @escaping (Bool) -> Void) {
        
        createRequest(with: URL(string: Constants.baseUrl + "Recipe/AddRecipe"), type: .POST) { baseRequest in
            
            var request = baseRequest
            
            let json = [
                "name": recipe.name,
                "authorName": recipe.authorName,
                "description": recipe.description,
                "time": recipe.time,
                "people": recipe.people,
                "imageUrl": recipe.imageUrl ?? "",
                "categoryId": recipe.category?.id ?? "",
                "ingridients": recipe.ingridients,
                "likes": 0
            ] as [String : Any]
            
            request.setValue(" application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: OperationQueue.main).dataTask(with: request)
            {
                data, response, error in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200,
                      error == nil
                else {
                    completion(false)
                    return
                }
                completion(true)

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
