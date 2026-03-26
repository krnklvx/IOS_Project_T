import SwiftUI
import SwiftData

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let order: Order

    @StateObject private var viewModel: OrderDetailViewModel
    @State private var isEditSheetPresented = false
    @State private var showDeleteAlert = false

    init(order: Order) {
        self.order = order
        _viewModel = StateObject(wrappedValue: OrderDetailViewModel(order: order))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .initial:
                EmptyView()
            case .loading:
                ProgressView("Загрузка...")
            case .failure(let message):
                ContentUnavailableView(
                    "Ошибка",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            case .loaded(let order):
                List {
                    Section("Клиент") {
                        LabeledContent("Имя", value: order.clientName)
                        LabeledContent("Изделие", value: order.productType)
                        LabeledContent("Вес/кол-во", value: order.quantityOrWeight)
                    }

                    Section("Сроки и статус") {
                        LabeledContent("Дата выдачи") {
                            Text(order.deadline, format: .dateTime.day().month().year().hour().minute())
                        }
                        LabeledContent("Статус", value: order.status.rawValue)
                    }

                    Section("Финансы") {
                        LabeledContent("Цена", value: viewModel.money(order.price))
                        LabeledContent("Себестоимость", value: viewModel.money(order.cost))
                        LabeledContent("Прибыль", value: viewModel.money(order.profit))
                            .foregroundStyle(order.profit >= 0 ? .green : .red)
                    }

                    if viewModel.hasNotes(order) {
                        Section("Комментарий") {
                            Text(order.notes)
                        }
                    }

                    Section {
                        Button("Удалить заказ", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
            }
        }
        .navigationTitle("Детали заказа")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Изменить") {
                    isEditSheetPresented = true
                }
            }
        }
        .sheet(isPresented: $isEditSheetPresented) {
            NavigationStack {
                OrderFormView(order: order)
            }
        }
        .alert("Удалить заказ?", isPresented: $showDeleteAlert) {
            Button("Удалить", role: .destructive, action: deleteOrder)
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Это действие нельзя отменить.")
        }
    }

    private func deleteOrder() {
        modelContext.delete(order)
        dismiss()
    }
}
