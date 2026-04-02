import SwiftUI
import SwiftData

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let order: Order

    @State private var isEditSheetPresented = false
    @State private var showDeleteAlert = false

    var body: some View {
        List {
            Section("Клиент") {
                LabeledContent("Имя", value: order.clientName)
                LabeledContent("Изделие", value: order.productType)
                LabeledContent("Вес/кол-во", value: order.quantityOrWeight)
            }

            if let rec = order.recipe {
                Section("Рецепт") {
                    LabeledContent("Из моих рецептов", value: rec.name)
                }
            }

            Section("Сроки и статус") {
                LabeledContent("Дата выдачи") {
                    Text(order.deadline, format: .dateTime.day().month().year().hour().minute())
                }
                LabeledContent("Статус", value: order.status.rawValue)
            }

            Section("Финансы") {
                LabeledContent("Цена", value: AppTheme.rubles(order.price))
                LabeledContent("Себестоимость", value: AppTheme.rubles(order.cost))
                LabeledContent("Прибыль", value: AppTheme.rubles(order.profit))
                    .foregroundStyle(order.profit >= 0 ? .green : .red)
            }

            if hasNotes {
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
        .navigationTitle("Детали заказа")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Изменить") {
                    isEditSheetPresented = true
                }
            }
        }
        .sheet(isPresented: $isEditSheetPresented) { // при нажатии кнопки изменить выходит форма
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

    private var hasNotes: Bool {
        !order.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func deleteOrder() { //удаление заказа из базы
        modelContext.delete(order)
        dismiss()
    }
}
