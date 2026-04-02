import SwiftUI
import SwiftData

struct OrderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    //запрос к бд получение рецептов отсорт по имени
    @Query(sort: \Recipe.name, order: .forward) private var recipes: [Recipe]

    private let order: Order?

    @StateObject private var viewModel = OrderFormViewModel()

    init(order: Order?) {
        self.order = order
    }

    var body: some View {
        Form {
            if let err = viewModel.saveError {
                Section {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section("Клиент и заказ") {
                TextField("Имя клиента", text: $viewModel.clientName)

                Picker("Изделие", selection: $viewModel.recipeID) { //вручную или автомат
                    Text("Вручную").tag(Optional<UUID>.none)
                    ForEach(recipes) { recipe in
                        Text(recipe.name).tag(Optional.some(recipe.id))
                    }
                }

                if viewModel.recipeID != nil {
                    HStack {
                        TextField(recipeUnitTitle + " заказа", text: $viewModel.recipeAmountText)
                            .keyboardType(.decimalPad)
                        Text(recipeUnitSuffix)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    TextField("Тип изделия (торт, капкейки...)", text: $viewModel.productType)
                    TextField("Вес или количество", text: $viewModel.quantityOrWeight)
                }

                DatePicker("Дата выдачи", selection: $viewModel.deadline, displayedComponents: [.date, .hourAndMinute])
            }

            Section("Финансы") {
                TextField("Цена", text: $viewModel.priceText)
                    .keyboardType(.decimalPad)
                TextField("Себестоимость", text: $viewModel.costText)
                    .keyboardType(.decimalPad)
            }

            Section("Статус и заметки") {
                Picker("Статус", selection: $viewModel.status) {
                    ForEach(OrderStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                TextField("Комментарий", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.softBackground)
        .navigationTitle(order == nil ? "Новый заказ" : "Редактировать")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Сохранить") {
                    if viewModel.save(order: order, recipes: recipes, modelContext: modelContext) {
                        dismiss()
                    }
                }
                .disabled(!viewModel.isFormValid) //неактивна если не валидна
            }
        }
        .onAppear {
            viewModel.load(from: order) //при открытии экрана или загрузка данных в форму или поля очищаются
        }
    }

    //находит выбранный рецепт
    private var selectedRecipe: Recipe? {
        recipes.first { $0.id == viewModel.recipeID }
    }

    private var recipeUnitSuffix: String {
        selectedRecipe?.baseUnitEnum.shortTitle ?? ""
    }

    private var recipeUnitTitle: String {
        guard let r = selectedRecipe else { return "Количество" }
        return r.baseUnitEnum == .grams ? "Вес" : "Кол-во"
    }
}
