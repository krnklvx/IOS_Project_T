import Foundation
import SwiftData

//форма заказа
///загрузка данных
///валидация
///сохранение
///преобразование текста в числа
@MainActor
final class OrderFormViewModel: ObservableObject { //отслеживает изменения внутри класса
    @Published var clientName = ""
    @Published var productType = ""
    @Published var quantityOrWeight = ""
    @Published var deadline = Date()
    @Published var priceText = ""
    @Published var costText = ""
    @Published var status: OrderStatus = .new
    @Published var notes = ""

    //связь с рецептом
    @Published var recipeID: UUID?
    @Published var recipeAmountText = ""

    //ошибка сохранения
    @Published var saveError: String?

    //метод или с рецепта или новые поля
    func load(from order: Order?) {
        saveError = nil
        recipeID = order?.recipe?.id //если у заказа есть рецепт сохраняем по айди
        recipeAmountText = ""

        //если заказ существует те редакция
        if let order {
            clientName = order.clientName
            productType = order.productType
            quantityOrWeight = order.quantityOrWeight
            deadline = order.deadline
            priceText = String(order.price)
            costText = String(order.cost)
            status = order.status
            notes = order.notes
            //если заказ связан с рецептом то вытаскиваем число
            if order.recipe != nil {
                recipeAmountText = Self.numberPrefix(from: order.quantityOrWeight)
            }
            //создание ноаого заказа
        } else {
            clientName = ""
            productType = ""
            quantityOrWeight = ""
            deadline = Date()
            priceText = ""
            costText = ""
            status = .new
            notes = ""
            recipeID = nil
        }
    }

    private static func numberPrefix(from s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespaces)
        let head = String(trimmed.prefix { $0.isNumber || $0 == "." || $0 == "," })
        return head.replacingOccurrences(of: ",", with: ".")
    }

    //можно ли сохранить форму
    var isFormValid: Bool {
        let priceOk = Double(priceText.replacingOccurrences(of: ",", with: ".")) != nil //текст цены в число
        //имя клиента не пустое и цена корректная
        guard !clientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, priceOk else {
            return false
        }
        //если заказ связан с рецептом то кол-во валидно и больше 0
        if recipeID != nil {
            guard let amt = Double(recipeAmountText.replacingOccurrences(of: ",", with: ".")), amt > 0 else {
                return false
            }
        }
        return recipeID != nil || !productType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save(order: Order?, recipes: [Recipe], modelContext: ModelContext) -> Bool {
        saveError = nil

        guard let price = Double(priceText.replacingOccurrences(of: ",", with: ".")) else {
            saveError = "Цена введена неверно"
            return false
        }
        //проверка себестоимости
        let cost = Double(costText.replacingOccurrences(of: ",", with: ".")) ?? 0
        //поиск выбранного рецепта
        let chosenRecipe = recipes.first { $0.id == recipeID }

        //если заказ редактируется
        if let order {
            order.clientName = clientName
            order.deadline = deadline
            order.price = price
            order.cost = cost
            order.status = status
            order.notes = notes
            //если выбран рецепт
            if let rec = chosenRecipe {
                order.recipe = rec //связываем заказ с рецептом
                order.productType = rec.name //из названия рецепта
                let amt = Double(recipeAmountText.replacingOccurrences(of: ",", with: ".")) ?? 0
                order.quantityOrWeight = formatQty(amt, unit: rec.baseUnitEnum.shortTitle)
            } else {
                //если рецепт не выбран то ручная
                order.recipe = nil
                order.productType = productType
                order.quantityOrWeight = quantityOrWeight
            }
            //если новый заказ то заказ на основе рецепта
        } else if let rec = chosenRecipe {
            let amt = Double(recipeAmountText.replacingOccurrences(of: ",", with: ".")) ?? 0
            let newOrder = Order(
                clientName: clientName,
                productType: rec.name,
                quantityOrWeight: formatQty(amt, unit: rec.baseUnitEnum.shortTitle),
                deadline: deadline,
                price: price,
                cost: cost,
                status: status,
                notes: notes,
                recipe: rec
            )
            modelContext.insert(newOrder) //добавляем в контекст
        } else {
            //если рецепт не выбран то создается ручной заказ
            let newOrder = Order(
                clientName: clientName,
                productType: productType,
                quantityOrWeight: quantityOrWeight,
                deadline: deadline,
                price: price,
                cost: cost,
                status: status,
                notes: notes,
                recipe: nil
            )
            modelContext.insert(newOrder) //добавляем в контекст
        }

        return true
    }

    private func formatQty(_ value: Double, unit: String) -> String {
        if value == floor(value) {
            return "\(Int(value)) \(unit)"
        }
        return "\(value) \(unit)"
    }
}
