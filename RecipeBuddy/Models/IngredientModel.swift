import SwiftData
import Foundation

@Model
final class IngredientEntity {
    var name: String
    var quantity: String
    
    init(name: String, quantity: String) {
        self.name = name
        self.quantity = quantity
    }
}

@Model
final class RecipeEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var tags: [String]
    var ingredients: [IngredientEntity]
    var minutes: Int
    var isThisWeek: Bool
    @Attribute(.externalStorage) var imageData: Data?
    
    init(id: UUID = UUID(),
         title: String,
         tags: [String],
         ingredients: [IngredientEntity],
         minutes: Int,
         isThisWeek: Bool = false,
         imageData: Data? = nil) {
        self.id = id
        self.title = title
        self.tags = tags
        self.ingredients = ingredients
        self.minutes = minutes
        self.isThisWeek = isThisWeek
        self.imageData = imageData
    }
}
