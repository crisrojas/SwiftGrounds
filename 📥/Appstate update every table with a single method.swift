//
//  KhipuCud.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

/// El objetivo de este playground es tener una metodología que me permita añadir arrays de entidades en el AppState
/// y que automáticamente tengamos los crud necesarios implementados.
///
///
/// Tengo mi app state con uno que otro array de entidades:
///
/// struct AppState {
///    var todos = [Todo]()
///    // ...
/// }
///
/// Quiero añadir un array de otro tipo, por ejemplo Users:
///
/// struct AppState {
///     var todos = [Todo]()
///     var users = [User]()
/// }
///
/// Automáticamente y sin hacer nada, puedo hacer esto:
///
/// appState.update(action: .upsert(User))
/// appState.update(action: .delete(User))
///
/// Dónde update toma un comando UpsertDelete (un enum) asciado a un tipo cualquiera, busca entre las propiedades de AppState un array
/// cuyos elementos correspondan a ese tipo y automáticamente gestiona ese array.
///

fileprivate struct ToDo: Identifiable, Equatable {
    let id: UUID
    var name: String
    var isChecked: Bool
    var projectId: UUID?
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false, projectId: UUID? = nil) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.projectId = projectId
    }
}

fileprivate struct Project: Identifiable {
    let id: UUID
    var name: String
}

/// @todo: repetido en el proyecto (ver UpsertDelete)
enum UD_Command<T> {
    case upsert(T)
    case delete(T)
}

fileprivate struct AppState {
    fileprivate(set) var todos    = [ToDo]()
    fileprivate(set) var projects = [Project]()
}


extension AppState {
    
    /// Actualmente, no he sido capaz de lograr lo que quiero, ya que
    /// en el método update, tengo que hacer un switch.
    ///
    /// func update(_ command: Update) -> Self {
    ///     var updatedCopy = self
    ///     switch command {
    ///     case .todos(let cmd): updatedCopy.todos.handle(cmd)
    ///     case .projects(let cmd): updatedCopy.projects.handle(cmd)
    ///     }
    ///     return updatedCopy
    /// }
    ///
    /// Lo más parecido es usar los keypath para seleccionar el array a modificar:
    ///
    mutating func update<T: Identifiable>(_ keyPath: WritableKeyPath<AppState, [T]>, with cmd: UD_Command<T>) {
        self[keyPath: keyPath].handle(cmd)
    }
    
    /// Lo que me parece suficientemente bueno, porque así disminuimos la cantidad de boilerplate.
    ///  Podemos si lo preferimos tener un método que devueva una nueva instancia:
    ///
    func updating<T: Identifiable>(_ keyPath: WritableKeyPath<AppState, [T]>, with cmd: UD_Command<T>) -> Self {
        var copy = self
        copy[keyPath: keyPath].handle(cmd)
        return copy
    }
    
    /// Este enfoque puede funcionar en la mayoría de los casos, pero hay algunos en los que no.
    /// Por ejemplo, para la entidad "Todo" del proyecto "Clon de Things", si quiero cambiar su tipo a "Project", voy a querer varias cosas
    /// - Editar el parentId = nil
    /// - Editar el actionGroupId = nil
    /// - Editar la checkList = []
    /// - Crear, para cada uno de sus check items un nuevo elemento Todo cuyo parentId sea el todo transformado en proyecto.
    ///
    /// Las tres primeras acciones se pueden codificar en el propio enum ListType:
    ///
    /// enum ListType {
    ///     case todo(parentId: UUID?, actionGroup: UUID?, checkItems: Set<CheckItem>)
    ///     case project
    ///     case actionGroup
    /// }
    ///
    /// Y bastaría con hacer esto:
    ///
    /// let updatedTodo = todo.updating(\.listType, to: .project)
    ///
    /// appState.updating(\.todos, action: \.upsert(updatedTodo))
    ///
    /// Pero la última acción no se puede codificar en el enum puesto que es una acción de creación y no de edición.
    /// Por tanto es una acción de un nivel superior que la entidad Todo no puede ejecutar, pero sí su dueño, en este caso AppState.
}

extension Array where Element: Identifiable {
    mutating func handle(_ command: UD_Command<Element>) {
        switch command {
        case .upsert(let item):
            self = filter { $0.id != item.id } + [item]
        case .delete(let item):
            self = filter { $0.id != item.id }
        }
    }
}


import XCTest

fileprivate final class StoreTests: XCTestCase {
    
    func test_update_with_keypath() {
        let sut = AppState()
        let todo = ToDo(name: "Do laundry")
        let updated = sut.updating(\.todos, with: .upsert(todo))
        let first = updated.todos.first
        XCTAssertEqual(first, todo)
    }
}
