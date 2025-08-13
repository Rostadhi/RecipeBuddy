//
//  RecipeStoreViewModel.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 13/08/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class RecipeStore: ObservableObject {
    @Published var recipes: [RecipeEntity] = []
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        load()
    }
    
    func load() {
        do {
            let all = try context.fetch(FetchDescriptor<RecipeEntity>())
            recipes = all
        } catch {
            print("Failed to fetch recipes: \(error)")
        }
    }
    
    func addRecipe(title: String, tags: [String], ingredients: [IngredientEntity], minutes: Int, isThisWeek: Bool) {
        let newRecipe = RecipeEntity(
            title: title,
            tags: tags,
            ingredients: ingredients,
            minutes: minutes,
            isThisWeek: isThisWeek
        )
        context.insert(newRecipe)
        save()
        load()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func shoppingList() -> String {
        var merged: [String: Double] = [:]
        var units: [String: String] = [:]
        
        let weekRecipes = recipes.filter { $0.isThisWeek }
        
        for recipe in weekRecipes {
            for ingredient in recipe.ingredients {
                let key = ingredient.name.lowercased()
                let (amount, unit) = Self.parseQuantity(ingredient.quantity)
                merged[key, default: 0] += amount
                units[key] = unit
            }
        }
        
        return merged
            .sorted { $0.key < $1.key }
            .map { key, total in
                let unit = units[key] ?? ""
                return "\(key.capitalized): \(total)\(unit.isEmpty ? "" : " \(unit)")"
            }
            .joined(separator: "\n")
    }
    
    static func parseQuantity(_ quantity: String) -> (Double, String) {
        let scanner = Scanner(string: quantity)
        var value: Double = 0
        if scanner.scanDouble(&value) {
            let unit = scanner.string[scanner.currentIndex...].trimmingCharacters(in: .whitespaces)
            return (value, unit)
        }
        return (0, quantity)
    }
}
