//
//  TagChip.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 13/08/25.
//

import Foundation
import SwiftUI

struct TagChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(
                    Capsule().fill(selected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.12))
                )
                .overlay(
                    Capsule().stroke(selected ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
