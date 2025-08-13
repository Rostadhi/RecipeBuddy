//
//  RecipeViewModel.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation
import Combine

@MainActor
final class RecipeViewModel: ObservableObject {
    enum State { case idle, loading, loaded, empty, error(String) }
    
    @Published var state: State = .idle
    @Published var all: [RecipeModel] = []
    @Published var filtered: [RecipeModel] = []
    @Published var query: String = ""
    @Published var hasStartedSearch: Bool = false
    
    let service: Service
    let favorites: Favorite
    private var bag = Set<AnyCancellable>()
    
    init(service: Service, favorites: Favorite = PersistentData()) {
        self.service = service
        self.favorites = favorites
        bindSearch()
    }
    
    func load() {
        Task {
            state = .loading
            do {
                let items = try await service.fetchRecipesFromJSON()
                self.all = items
                self.filtered = items
                self.state = .loaded
            } catch {
                self.state = .error((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
            
            }
        }
    }
    
    private func bindSearch() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.applyFilter() }
            .store(in: &bag)
        
        $all
            .sink { [weak self] _ in self?.applyFilter() }
            .store(in: &bag)
    }
    
    private func applyFilter() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else {
            filtered = all
            return
        }
        filtered = all.filter { r in
            r.title.lowercased().contains(q) ||
            r.ingredients.contains { ($0.name ?? "").lowercased().contains(q) }
        }
        if case .idle = state { state = .loaded } else if case .loading = state { state = .loaded }
    }
    
    func setSearchActive(_ active: Bool) {
        if active { hasStartedSearch = true }
    }
    
    func isFavorite(_ id: String) -> Bool { favorites.isFavorite(id) }
    func toggleFavorite(_ id: String) { favorites.toggle(id); objectWillChange.send() }
}
