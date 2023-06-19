//
//  Register.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 19.06.23.
//

import Foundation

struct User: Codable {
    let firstname: String
    let lastname: String
    let email: String
    let userName: String
    let password: String?
}
