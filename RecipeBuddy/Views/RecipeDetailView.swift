//
//  RecipeDetailView.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation
import SwiftUI
import Kingfisher

struct RecipeDetailView: View {
    let recipe: RecipeModel
    let favorites: Favorite
    @State private var isFav: Bool = false
    @State private var obtained: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                KFImage(recipe.imageURL)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            favorites.toggle(recipe.id)
                            isFav.toggle()
                        } label: {
                            Image(systemName: isFav ? "heart.fill" : "heart")
                                .foregroundStyle(isFav ? .red : .white)
                                .padding(10)
                                .background(.black.opacity(0.25), in: Circle())
                                .padding()
                        }
                        .accessibilityLabel(isFav ? "Remove Favorite" : "Add Favorite")
                    }

                Text(recipe.title).font(.title.bold())

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients").font(.headline)
                    ForEach(recipe.ingredients, id: \.self) { ing in
                        let key = ing.key
                        Button {
                            if obtained.contains(key) { obtained.remove(key) } else { obtained.insert(key) }
                        } label: {
                            HStack {
                                Image(systemName: obtained.contains(key) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(obtained.contains(key) ? .green : .secondary)
                                Text([ing.quantity, ing.name].compactMap { $0 }.joined(separator: " "))
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 2)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Method").font(.headline)
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(idx + 1).").bold().foregroundStyle(.secondary)
                            Text(step)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Spacer(minLength: 16)
            }
            .padding(16)
        }
        .navigationTitle("Recipe")
        .onAppear { isFav = favorites.isFavorite(recipe.id) }
    }
}
