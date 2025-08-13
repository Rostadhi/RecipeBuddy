//
//  RecipeBuddyApp.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import SwiftUI
import SwiftData

@main
struct RecipeBuddyApp: App {
    init() {
        URLCache.shared = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024
        )
    }
    var body: some Scene {
        WindowGroup {
            RecipeView()
        }
        .modelContainer(for: [RecipeEntity.self, IngredientEntity.self])
    }
}
