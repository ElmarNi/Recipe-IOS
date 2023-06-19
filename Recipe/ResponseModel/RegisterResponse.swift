//
//  RegisterResponse.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 19.06.23.
//

import Foundation

struct RegisterResponse: Codable {
    let code: Int
    let description: String?
    let userId: String?
}
