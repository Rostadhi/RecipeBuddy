//
//  JSONRecipeService.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation

enum DataSource: Equatable {
    case bundled
    case remote(URL)
}

protocol Service {
    func load(from source: DataSource) async throws -> [RecipeModel]
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

    func load(from source: DataSource) async throws -> [RecipeModel] {
        switch source {
        case .bundled:
            return try await loadBundled()
        case .remote(let url):
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                let items = try decode(data)
                if items.isEmpty { throw ServiceError.emptyFile(filename: filename) }
                return items
            } catch {
                // graceful fallback
                return try await loadBundled()
            }
        }
    }

    private func loadBundled() async throws -> [RecipeModel] {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            throw ServiceError.fileNotFound(filename: filename, bundle: bundle)
        }
        let data: Data = try await Task.detached(priority: .userInitiated) {
            try Data(contentsOf: url)
        }.value
        return try decode(data)
    }

    private func decode(_ data: Data) throws -> [RecipeModel] {
        do {
            return try JSONDecoder().decode([RecipeModel].self, from: data)
        } catch {
            throw ServiceError.decodeFailed(underlying: error)
        }
    }
}
