# RecipeBuddy

RecipeBuddy is a SwiftUI app for browsing, searching, and favoriting recipes loaded from a bundled JSON file.  
It uses **MVVM**, a **Repository** protocol for data access, **async/await** for loading, **Combine** for debounced search, and **Kingfisher** for images. 

---

## Features

- **Home list**: Thumbnail, title, tags, and estimated minutes.
- **Detail screen**: Large image, ingredients list (checkable UI state), and step‑by‑step method.
- **Search**: Debounced (300ms), matches by **title** or **ingredient**.
- **Empty & error states**: Friendly, retry supported.
- **Favorites**: Toggle in list & detail; persisted.

---

## Tech & Architecture

- **SwiftUI** (iOS 17+), **Swift 5.9+**, **Xcode 15+**
- **MVVM**:
  - `RecipeViewModel` (home) manages loading, filtering, and favorites.
  - `RecipeDetailView` manages ingredient check state (UI‑only).
- **Repository** abstraction:
  - `Service` protocol
  - `JSONRecipeService` (bundled JSON)
- **Persistence** abstraction:
  - `Favorite` protocol
  - `PersistentData` (UserDefaults)
- **Kingfisher** for remote images

---

## JSON Schema (example)

`Resources/recipe.json`

## How to code this project
1. Copy the json file and create new json file
2. Create Model based on json file
3. Create a class for handling fetching and processing the data
4. Create view model to prepare and load the data 
5. Pass the data from fetching and processsing class into viewmodel class
6. Pass data from view model to view

