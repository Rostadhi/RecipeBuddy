import SwiftUI
import PhotosUI
import Photos
import UIKit

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImagesData: [Data] = []
    @State private var photoAuthStatus: PHAuthorizationStatus = .notDetermined
    
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
                Section("Photo") {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 0, // 0 = no limit
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Choose Images", systemImage: "photo.on.rectangle")
                    }

                    if !selectedImagesData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedImagesData.enumerated()), id: \.offset) { _, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }

                    if photoAuthStatus == .limited {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Access is limited to selected photos.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button("Select More Photos…") {
                                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                                        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: root)
                                    }
                                }
                                Button("Open Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
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
                        let newRecipe = RecipeEntity(
                            title: title,
                            tags: tagList,
                            ingredients: ingredients,
                            minutes: Int(minutes) ?? 0,
                            isThisWeek: isThisWeek,
                            imageData: selectedImagesData.first
                        )

                        context.insert(newRecipe)
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            print("Save error: \(error)")
                        }
                    }
                    .disabled(title.isEmpty || ingredients.isEmpty)
                }
            }
            .onChange(of: selectedItems) { items in
                Task {
                    var datas: [Data] = []
                    for item in items {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            datas.append(data)
                        }
                    }
                    selectedImagesData = datas
                }
            }
            .onAppear {
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                if status == .notDetermined {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                        DispatchQueue.main.async {
                            self.photoAuthStatus = newStatus
                        }
                    }
                } else {
                    self.photoAuthStatus = status
                }
            }
        }
    }
}
