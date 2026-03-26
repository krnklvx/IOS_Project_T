import SwiftUI
import SwiftData

struct OrderFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let order: Order?

    @StateObject private var viewModel = OrderFormViewModel()

    init(order: Order?) {
        self.order = order
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .initial:
                ProgressView("Подготовка формы...")

            case .loading:
                ProgressView("Загрузка...")

            case .saving:
                ProgressView("Сохраняем...")

            case .failure(let message):
                formView
                    .overlay(alignment: .top) {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.top, 4)
                    }

            case .editing:
                formView
            }
        }
        .navigationTitle(order == nil ? "Новый заказ" : "Редактировать")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Отмена") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Сохранить") {
                    save()
                }
                .disabled(!viewModel.isFormValid)
            }
        }
        .onAppear {
            viewModel.setup(with: order)
        }
    }

    private var formView: some View {
        Form {
            Section("Клиент и заказ") {
                TextField("Имя клиента", text: $viewModel.clientName)
                TextField("Тип изделия (торт, капкейки...)", text: $viewModel.productType)
                TextField("Вес или количество", text: $viewModel.quantityOrWeight)
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
    }

    private func save() {
        let saved = viewModel.save(order: order, modelContext: modelContext)
        if saved {
            dismiss()
        }
    }
}
