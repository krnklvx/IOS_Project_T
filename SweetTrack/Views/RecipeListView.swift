import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]

    @State private var searchText = ""
    @State private var isEditorPresented = false
    @State private var recipeToEdit: Recipe?

    private var filtered: [Recipe] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return recipes }
        return recipes.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        recipes.isEmpty ? "Рецептов пока нет" : "Ничего не найдено",
                        systemImage: "heart.text.square",
                        description: Text(
                            recipes.isEmpty
                            ? "Нажми + и добавь первый рецепт."
                            : "Попробуй другой запрос."
                        )
                    )
                } else {
                    List {
                        ForEach(filtered) { recipe in
                            Button {
                                recipeToEdit = recipe
                                isEditorPresented = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "birthday.cake.fill")
                                        .foregroundStyle(AppTheme.accent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recipe.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("База: \(formatBase(recipe))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteRecipes)
                    }
                    .scrollContentBackground(.hidden)
                    .background(AppTheme.softBackground)
                }
            }
            .navigationTitle("Мои рецепты")
            .searchable(text: $searchText, prompt: "Поиск по изделию")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        recipeToEdit = nil
                        isEditorPresented = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $isEditorPresented) {
                NavigationStack {
                    RecipeFormView(recipe: recipeToEdit)
                }
            }
            .background(AppTheme.softBackground)
        }
    }

    private func formatBase(_ recipe: Recipe) -> String {
        let u = recipe.baseUnitEnum
        let n = recipe.baseAmount
        let s = n == floor(n) ? String(format: "%.0f", n) : String(format: "%.1f", n)
        return "\(s) \(u.shortTitle)"
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}
