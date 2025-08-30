//
//  RecipeView.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import SwiftUI
import SwiftData
import UIKit

struct RecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecipeEntity.title) private var recipes: [RecipeEntity]
    @State private var showingAdd = false
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(recipes) { r in
                    HStack {
                        if let data = r.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text(r.title).font(.headline)
                            if !r.tags.isEmpty {
                                Text(r.tags.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Label("\(r.minutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if r.isThisWeek {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .onDelete(perform: deleteRecipe)
            }
            .scrollContentBackground(.hidden)
            .background(
                Image("image_recipe_buddy")
                    .resizable()
                    .ignoresSafeArea()
                    .opacity(0.3)
            )
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Add recipe", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addRecipeButton")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddRecipeView()
        }
    
    }
    
    private func deleteRecipe(at offsets: IndexSet) {
        for index in offsets {
            let recipe = recipes[index]
            modelContext.delete(recipe)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}
