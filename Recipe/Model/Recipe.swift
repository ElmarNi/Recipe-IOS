//
//  Recipe.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 06.06.23.
//

import Foundation

struct Recipe: Codable {
    let authorName: String
    let category: Category
    let description: String
    let id: Int
    let imageUrl: String?
    let ingridients: String
    let likes: Int
    let name: String
    let people: Int
    let time: String
}
