//
//  Grouping with dictionnaries.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

/*
keywords: v-labs menuz
#snippets #devgrounds
*/
import Foundation

/// Tenemos una lista de la compra cuyos items pueden estar asociados o no a un ingrediente.
struct ShoppingListItem {
    let name: String
    let ingredientId: UUID?
    let isChecked: Bool
}

/// El ingrediente siempre está asociado a una categoría
struct Ingredient {
    let id = UUID()
    let name: String
    let categoryId: UUID
}

struct Category {
    let id = UUID()
    let name: String
}


/// En nuestra lista, queremos msotrar los items en secciones,
/// agrupados por categorías:
struct ShoppingListSection {
    let name: String
    let items: [ShoppingListItem]
}


/// Modelo de datos:
var categories  = [Category(name: "Carnes"), Category(name: "Lácteos"), Category(name: "Legumbres")]
var ingredients = [
    Ingredient(name: "Pollo"   , categoryId: categories[0].id),
    Ingredient(name: "Yogurt"  , categoryId: categories[1].id),
    Ingredient(name: "Queso"   , categoryId: categories[1].id),
    Ingredient(name: "Frijoles", categoryId: categories[2].id)
]

var shoppingListItems = ingredients.map { ShoppingListItem(name: $0.name, ingredientId: $0.id, isChecked: false) }


/// Conformance to hashable for grouping in dictionnary
extension Category: Hashable {}

/// Get categories of ingredient from its id. Return unknown category if nothing is found
fileprivate func getCategoryFromIngredient(id: UUID?) -> Category {
    // Must return same "unknown" symbol in both cases: guard and return coalescing
    let unknown = Category(name: "Unknown")
    
    guard
    let id = id,
    let ingredient = ingredients.first(where: { $0.id == id })
    else { return unknown }
    
    let categoryId = ingredient.categoryId
    let category   = categories.first(where: { $0.id == categoryId })
    return category ?? unknown
}

/// Grouping
let sections = Dictionary(
    grouping: shoppingListItems,
    by: { getCategoryFromIngredient(id: $0.ingredientId) }
).map { category, items in
    ShoppingListSection(name: category.name, items: items)
}

//dump(sections)
