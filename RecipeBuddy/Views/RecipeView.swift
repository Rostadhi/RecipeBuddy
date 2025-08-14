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
    @State private var showingSettings = false
    
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
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
        .sheet(isPresented: $showingSettings) {
            SettingsView(vm: vm)
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
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var remoteURL: URL {
        URL(string: "https://raw.githubusercontent.com/Rostadhi/RecipeBuddy/1b08b627792c0fd1409a2cc9c1e4261506ed5183/RecipeBuddy/Resource/Recipe.json")!
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
                List(vm.filtered, id: \.id) { r in
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

struct SettingsView: View {
    @ObservedObject var vm: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(vm.allTags, id: \.self) { tag in
                Button(action: {
                    if vm.selectedTags.contains(tag) {
                        vm.selectedTags.remove(tag)
                    } else {
                        vm.selectedTags.insert(tag)
                    }
                }) {
                    HStack {
                        Text(tag)
                        Spacer()
                        if vm.selectedTags.contains(tag) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
