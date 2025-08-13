//
//  JSONRecipeService.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation

protocol Service {
    func fetchRecipesFromJSON() async throws -> [RecipeModel]
}

enum ServiceError: LocalizedError {
    case fileNotFound(filename: String, bundle: Bundle)
    case emptyFile(filename: String)
    case decodeFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name, _):
            return "Could not find \(name).json in the app bundle."
        case .emptyFile(let name):
            return "\(name).json contains no recipes."
        case .decodeFailed(let err):
            return "Failed to decode recipes.json: \(err.localizedDescription)"
        }
    }
}

struct JSONRecipeService: Service {
    let filename: String
    let bundle: Bundle

    init(filename: String = "Recipe", bundle: Bundle = .main) {
        self.filename = filename
        self.bundle = bundle
    }

    func fetchRecipesFromJSON() async throws -> [RecipeModel] {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw ServiceError.fileNotFound(filename: filename, bundle: bundle)
        }
        let data: Data = try await Task.detached(priority: .userInitiated) {
            try Data(contentsOf: url)
        }.value

        do {
            let items = try JSONDecoder().decode([RecipeModel].self, from: data)
            if items.isEmpty { throw ServiceError.emptyFile(filename: filename) }
            return items
        } catch {
            throw ServiceError.decodeFailed(underlying: error)
        }
    }
}
