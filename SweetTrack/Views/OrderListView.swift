import SwiftUI
import SwiftData

struct OrderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Order.deadline, order: .forward) private var orders: [Order]

    @StateObject private var viewModel = OrderListViewModel()
    @State private var isCreateSheetPresented = false
    @State private var deadlineSort: DeadlineSort = .nearestFirst

    var body: some View {
        NavigationStack {
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
                case .loaded(let filteredOrders):
                    if filteredOrders.isEmpty {
                        if orders.isEmpty {
                            ContentUnavailableView(
                                "Заказов пока нет",
                                systemImage: "birthday.cake",
                                description: Text("Нажми + и создай первый заказ.")
                            )
                        } else {
                            ContentUnavailableView(
                                "Ничего не найдено",
                                systemImage: "magnifyingglass",
                                description: Text("Попробуй другой текст в поиске.")
                            )
                        }
                    } else {
                        let visibleOrders = sortedOrders(filteredOrders)
                        List {
                            Section {
                                DashboardCardView(orders: filteredOrders)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowBackground(Color.clear)
                            }

                            Section("Заказы") {
                                ForEach(visibleOrders) { order in
                                    NavigationLink {
                                        OrderDetailView(order: order)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(order.clientName)
                                                    .font(.headline)
                                                Spacer()
                                                Text(order.status.rawValue)
                                                    .font(.caption)
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(.blue)
                                                    .clipShape(Capsule())
                                            }

                                            Text(order.productType)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)

                                            HStack {
                                                Label {
                                                    Text(order.deadline, format: .dateTime.day().month().year())
                                                } icon: {
                                                    Image(systemName: "calendar")
                                                }

                                                Spacer()

                                                Text("Прибыль: \(money(order.profit))")
                                                    .font(.caption)
                                                    .foregroundStyle(order.profit >= 0 ? .green : .red)
                                            }
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }
                                        .padding(.vertical, 6)
                                    }
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                                .onDelete { offsets in
                                    deleteOrders(at: offsets, from: visibleOrders)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("SweetTrack")
            .searchable(text: $viewModel.searchText, prompt: "Поиск по клиенту или изделию")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Сортировка", selection: $deadlineSort) {
                            Text("Сначала ближайшие").tag(DeadlineSort.nearestFirst)
                            Text("Сначала поздние").tag(DeadlineSort.latestFirst)
                        }
                    } label: {
                        Label("Сортировка", systemImage: "arrow.up.arrow.down.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isCreateSheetPresented = true
                    } label: {
                        Label("Новый заказ", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreateSheetPresented) {
                NavigationStack {
                    OrderFormView(order: nil)
                }
            }
            .onAppear {
                viewModel.loadData(from: orders)
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.loadData(from: orders)
            }
            .onChange(of: orders.count) { _, _ in
                viewModel.loadData(from: orders)
            }
        }
    }

    private func deleteOrders(at offsets: IndexSet, from filteredOrders: [Order]) {
        for index in offsets {
            modelContext.delete(filteredOrders[index])
        }
    }

    private func sortedOrders(_ orders: [Order]) -> [Order] {
        switch deadlineSort {
        case .nearestFirst:
            return orders.sorted { $0.deadline < $1.deadline }
        case .latestFirst:
            return orders.sorted { $0.deadline > $1.deadline }
        }
    }

    private func money(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(0...2)))) ₽"
    }
}

private enum DeadlineSort {
    case nearestFirst
    case latestFirst
}

private struct DashboardCardView: View {
    let orders: [Order]

    private var totalRevenue: Double {
        orders.reduce(0) { $0 + $1.price }
    }

    private var totalCost: Double {
        orders.reduce(0) { $0 + $1.cost }
    }

    private var totalProfit: Double {
        totalRevenue - totalCost
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                stat("Заказов", "\(orders.count)")
                Spacer()
                stat("Выручка", money(totalRevenue))
                Spacer()
                stat("Прибыль", money(totalProfit))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
        }
    }

    private func money(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(0...2)))) ₽"
    }
}
