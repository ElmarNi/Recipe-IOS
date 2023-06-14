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
    
}
