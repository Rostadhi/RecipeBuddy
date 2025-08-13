import SwiftUI

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @ObservedObject var store: RecipeStore
    
    @State private var title = ""
    @State private var tags = ""
    @State private var minutes = ""
    @State private var isThisWeek = false
    @State private var ingredients: [IngredientEntity] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Tags (comma separated)", text: $tags)
                    TextField("Minutes", text: $minutes).keyboardType(.numberPad)
                    Toggle("This Week's Plan", isOn: $isThisWeek)
                }
                
                Section("Ingredients") {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Name", text: Binding(
                                get: { ingredients[index].name },
                                set: { ingredients[index].name = $0 }
                            ))
                            TextField("Quantity", text: Binding(
                                get: { ingredients[index].quantity },
                                set: { ingredients[index].quantity = $0 }
                            ))
                        }
                    }
                    Button("Add Ingredient") {
                        ingredients.append(IngredientEntity(name: "", quantity: ""))
                    }
                }
            }
            .navigationTitle("New Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let tagList = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        store.addRecipe(
                            title: title,
                            tags: tagList,
                            ingredients: ingredients,
                            minutes: Int(minutes) ?? 0,
                            isThisWeek: isThisWeek
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty)
                }
            }
        }
    }
}
