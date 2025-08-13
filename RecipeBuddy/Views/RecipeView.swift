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
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false
    
    init(service: Service = JSONRecipeService(),
         favorites: Favorite = PersistentData()) {
        _vm = StateObject(wrappedValue: RecipeViewModel(service: service, favorites: favorites))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                controls
                content
            }
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
        .searchable(text: $vm.query, prompt: "Search by title or ingredient")
        .onChange(of: isSearching) { newValue in
            vm.setSearchActive(newValue)
        }
        .task { if case .idle = vm.state { vm.load() } }
        .sheet(isPresented: $showingAdd) {
            AddRecipeView(store: RecipeStore(context: modelContext))
        }
    }
    
    private var controls: some View {
        VStack(spacing: 10) {
            // Sort and Data Source Pickers side by side
            HStack(spacing: 12) {
                Picker("Sort", selection: $vm.sortOrder) {
                    Text("Time ↑").tag(RecipeViewModel.SortOrder.shortest)
                    Text("Time ↓").tag(RecipeViewModel.SortOrder.longest)
                }
                .pickerStyle(.segmented)
                Picker("Data", selection: Binding(
                    get: { vm.dataSource == .bundled ? 0 : 1 },
                    set: { vm.dataSource = $0 == 0 ? .bundled : .remote(remoteURL) }
                )) {
                    Text("Bundled").tag(0)
                    Text("Remote").tag(1)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(vm.allTags, id: \.self) { tag in
                        TagChip(label: tag, selected: vm.selectedTags.contains(tag)) {
                            if vm.selectedTags.contains(tag) {
                                vm.selectedTags.remove(tag)
                            } else {
                                vm.selectedTags.insert(tag)
                            }
                        }
                        .font(.caption)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(vm.selectedTags.contains(tag) ? Color.accentColor.opacity(0.15) : Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var remoteURL: URL {
        URL(string: "https://github.com/Rostadhi/RecipeBuddy/tree/1b08b627792c0fd1409a2cc9c1e4261506ed5183/RecipeBuddy/Resource/Recipe.json")!
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
