//
//  PersistentData.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation

protocol Favorite {
    func all() -> Set<String>
    func isFavorite(_ id: String) -> Bool
    func toggle(_ id: String)
}

final class PersistentData: Favorite {
    private let key = "com.recipe.RecipeBuddy"
    private let defaults = UserDefaults.standard

    func all() -> Set<String> { Set(defaults.stringArray(forKey: key) ?? []) }
    func isFavorite(_ id: String) -> Bool { all().contains(id) }
    func toggle(_ id: String) {
        var set = all()
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
        defaults.set(Array(set), forKey: key)
    }
}
