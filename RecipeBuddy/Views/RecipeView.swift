//
//  RecipeView.swift
//  RecipeBuddy
//
//  Created by rostadhi akbar on 12/08/25.
//

import Foundation
import SwiftUI
import Kingfisher

struct RecipeView: View {
    @StateObject private var vm: RecipeViewModel
    @Environment(\.isSearching) private var isSearching
    
    init(service: Service = JSONRecipeService(),
         favorites: Favorite = PersistentData()) {
        _vm = StateObject(wrappedValue: RecipeViewModel(service: service, favorites: favorites))
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Recipes")
        }
        .searchable(text: $vm.query, prompt: "Search by title or ingredient")
        .onChange(of: isSearching) { searching in
            vm.setSearchActive(searching)
        }
        .task {
            if case .idle = vm.state { vm.load() }
        }
        
        .onAppear {
            if case .idle = vm.state { vm.load() }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle, .loading:
            ProgressView("Loading…").frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .error(let msg):
            EmptyStateView(systemImage: "exclamationmark.triangle.fill",
                           title: "Something went wrong",
                           message: msg,
                           actionTitle: "Retry",
                           action: { vm.load() })
            
        case .loaded, .empty:
            if vm.hasStartedSearch && !vm.query.isEmpty && vm.filtered.isEmpty {
                EmptyStateView(systemImage: "magnifyingglass",
                               title: "No results",
                               message: "Try a different search.")
            } else {
                List(vm.query.isEmpty ? vm.all : vm.filtered, id: \.id) { r in
                    NavigationLink {
                        RecipeDetailView(recipe: r, favorites: vm.favorites)
                    } label: {
                        RecipeRow(recipe: r,
                                  isFavorite: vm.isFavorite(r.id),
                                  onFavorite: { vm.toggleFavorite(r.id) })
                    }
                }
                .listStyle(.plain)
                .overlay(
                    Group {
                        if vm.all.isEmpty, case .loaded = vm.state, vm.query.isEmpty {
                            EmptyStateView(
                                systemImage: "tray",
                                title: "No bundled recipes",
                                message: "Your service returned 0 items. Check recipe.json filename & Target Membership."
                            )
                        }
                    }
                )
            }
        }
    }
    
}
