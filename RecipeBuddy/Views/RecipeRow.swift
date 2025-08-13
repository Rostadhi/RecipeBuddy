//
//  RecipeRow.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation
import SwiftUI
import Kingfisher

struct RecipeRow: View {
    let recipe: RecipeModel
    let isFavorite: Bool
    let onFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            KFImage(recipe.imageURL)
                .placeholder { ProgressView() }
                .cancelOnDisappear(true)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.title).font(.headline).lineLimit(1)
                    Spacer()
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isFavorite ? "Remove Favorite" : "Add Favorite")
                }

                HStack(spacing: 8) {
                    ForEach(recipe.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color(.systemGray6), in: Capsule())
                    }
                }

                Label("\(recipe.minutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
