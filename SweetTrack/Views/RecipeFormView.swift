import SwiftUI
import SwiftData

private struct IngredientDraft: Identifiable {
    let id = UUID()
    var name: String
    var amount: String
    var unit: String
}

struct RecipeFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe?

    @State private var name = ""
    @State private var baseUnit: RecipeBaseUnit = .grams
    @State private var baseAmountText = "1000"
    @State private var ingredientRows: [IngredientDraft] = []
    @State private var stepLines: [String] = [""]

    var body: some View {
        Form {
            Section("Изделие") {
                TextField("Название", text: $name)
                Picker("Единица рецепта", selection: $baseUnit) {
                    ForEach(RecipeBaseUnit.allCases) { u in
                        Text(u.pickerTitle).tag(u)
                    }
                }
                TextField(baseUnit == .grams ? "На сколько грамм (база)" : "За сколько штук (база)", text: $baseAmountText)
                    .keyboardType(.decimalPad)
            }

            Section("Ингредиенты") {
                ForEach($ingredientRows) { $row in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Название", text: $row.name)
                        HStack {
                            TextField("Кол-во", text: $row.amount)
                                .keyboardType(.decimalPad)
                            TextField("ед.", text: $row.unit)
                                .frame(width: 44)
                        }
                    }
                }
                .onDelete { ingredientRows.remove(atOffsets: $0) }

                Button {
                    ingredientRows.append(IngredientDraft(name: "", amount: "", unit: baseUnit.shortTitle))
                } label: {
                    Label("Добавить ингредиент", systemImage: "plus.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                }
            }

            Section("Шаги приготовления") {
                ForEach(stepLines.indices, id: \.self) { i in
                    TextField("Шаг \(i + 1)", text: Binding(
                        get: { stepLines[i] },
                        set: { stepLines[i] = $0 }
                    ))
                }
                .onDelete { stepLines.remove(atOffsets: $0) }

                Button {
                    stepLines.append("")
                } label: {
                    Label("Добавить шаг", systemImage: "plus.circle")
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.softBackground)
        .navigationTitle(recipe == nil ? "Новый рецепт" : "Рецепт")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Закрыть") { dismiss() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Сохранить") { save() }
                    .disabled(!canSave)
            }
        }
        .onAppear(perform: loadIfEditing)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(baseAmountText.replacingOccurrences(of: ",", with: ".")) != nil
    }

    private func loadIfEditing() {
        guard let recipe else {
            if ingredientRows.isEmpty {
                ingredientRows = [IngredientDraft(name: "", amount: "", unit: "г")]
            }
            return
        }
        name = recipe.name
        baseUnit = recipe.baseUnitEnum
        baseAmountText = formatNumber(recipe.baseAmount)
        ingredientRows = recipe.ingredients
            .sorted { $0.sortIndex < $1.sortIndex }
            .map { IngredientDraft(name: $0.name, amount: formatNumber($0.amount), unit: $0.unit) }
        let steps = recipe.steps.sorted { $0.sortIndex < $1.sortIndex }.map(\.text)
        stepLines = steps.isEmpty ? [""] : steps
    }

    private func formatNumber(_ x: Double) -> String {
        x == floor(x) ? String(format: "%.0f", x) : String(format: "%.2f", x)
    }

    private func save() {
        let base = Double(baseAmountText.replacingOccurrences(of: ",", with: ".")) ?? 1
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        let target: Recipe
        if let recipe {
            target = recipe
            target.name = trimmedName
            target.baseUnitRaw = baseUnit.rawValue
            target.baseAmount = base
        } else {
            let newRecipe = Recipe(name: trimmedName, baseUnit: baseUnit, baseAmount: base)
            modelContext.insert(newRecipe)
            target = newRecipe
        }

        for ing in target.ingredients {
            modelContext.delete(ing)
        }
        for st in target.steps {
            modelContext.delete(st)
        }

        var sortI = 0
        for row in ingredientRows {
            let trimmed = row.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let amt = Double(row.amount.replacingOccurrences(of: ",", with: ".")) ?? 0
            let unit = row.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? baseUnit.shortTitle : row.unit
            let ing = RecipeIngredient(name: trimmed, amount: amt, unit: unit, sortIndex: sortI, recipe: target)
            modelContext.insert(ing)
            sortI += 1
        }

        let stepsToSave = stepLines.enumerated().filter { !$0.element.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        for (i, text) in stepsToSave {
            let st = RecipeStep(
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                sortIndex: i,
                recipe: target
            )
            modelContext.insert(st)
        }

        dismiss()
    }
}
