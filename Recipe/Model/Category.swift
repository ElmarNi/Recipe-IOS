//
//  Category.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 01.06.23.
//

import Foundation

struct Category: Codable {
    let id: Int
    let name: String
    let imageUrl: String?
    let iconUrl: String?
}
