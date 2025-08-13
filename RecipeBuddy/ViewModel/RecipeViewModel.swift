//
//  RecipeViewModel.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class RecipeViewModel: ObservableObject {
    enum State { case idle, loading, loaded, empty, error(String) }
    enum SortOrder: String, CaseIterable { case shortest = "Time ↑", longest = "Time ↓" }
    
    @Published var state: State = .idle
    @Published var all: [RecipeModel] = []
    @Published var filtered: [RecipeModel] = []
    @Published var query: String = ""
    @Published var hasStartedSearch: Bool = false
    
    @Published var sortOrder: SortOrder = .shortest { didSet { applyFilter() } }
    @Published var selectedTags: Set<String> = [] { didSet { applyFilter() } }
    @Published var dataSource: DataSource = .bundled { didSet { load() } }
    
    let service: Service
    let favorites: Favorite
    private var bag = Set<AnyCancellable>()
    
    init(service: Service, favorites: Favorite = PersistentData()) {
        self.service = service
        self.favorites = favorites
        bindSearch()
    }
    
    var allTags: [String] {
        Array(Set(all.flatMap(\.tags))).sorted()
    }
    
    func load() {
        Task {
            state = .loading
            do {
                let items = try await service.load(from: dataSource)
                self.all = items
                self.state = items.isEmpty ? .empty : .loaded
                self.applyFilter()
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
        var base = all
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            base = base.filter { r in
                r.title.lowercased().contains(q) ||
                r.ingredients.contains { ($0.name ?? "").lowercased().contains(q) }
            }
        }
        
        if !selectedTags.isEmpty {
            base = base.filter { Set($0.tags).isSuperset(of: selectedTags) }
        }
        
        switch sortOrder {
        case .shortest: filtered = base.sorted { $0.minutes < $1.minutes }
        case .longest:  filtered = base.sorted { $0.minutes > $1.minutes }
        }
    }
    
    func setSearchActive(_ active: Bool) { if active { hasStartedSearch = true } }
    func isFavorite(_ id: String) -> Bool { favorites.isFavorite(id) }
    func toggleFavorite(_ id: String) { favorites.toggle(id); objectWillChange.send() }
}
