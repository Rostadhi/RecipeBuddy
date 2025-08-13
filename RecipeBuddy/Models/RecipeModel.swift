//
//  RecipeModel.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation

struct RecipeModel: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let tags: [String]
    let minutes: Int
    let image: String
    let ingredients: [IngredientModel]
    let steps: [String]
    
    var imageURL: URL? { URL(string: image) }
}

struct IngredientModel: Codable, Equatable, Hashable {
    let name: String?
    let quantity: String?
    
    var key: String { (name ?? "") + "|" + (quantity ?? "") }
}

struct IngredientInput: Identifiable, Hashable {
    let id = UUID()
    var name: String = ""
    var quantity: String = ""
}

