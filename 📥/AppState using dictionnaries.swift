//
//  Store.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 15/11/23.
//

import Foundation

// Upsert Delete Command
enum UpsertDelete<T> {
    case upsert(T)
    case delete(T)
}

// MARK: - AppState
/// Tenemos un AppState
/// Con diccionarios que actúan como tablas en una base de datos.
/// Usamos diccionarios en lugar de arrays por simplicidad a la hora de actualizar/eliminar
fileprivate struct AppState  {
    var users = [UUID: User]()
    var todos = [UUID: Todo]()
}

// AppState tiene entidades asociadas que almacena
extension AppState {
    struct Todo: Codable {
        var id = UUID()
        var title: String?
        var isChecked = false
    }
    
    struct User: Codable {
        var id = UUID()
        var name: String
    }
}

/// Updatable API
/// El AppState es modificado a través de una api que devuelve una nueva versión.
/// La idea es que la antigua versión sea reemplazada por la nueva cada vez que se hace un cambio.
extension AppState   {
    func updated(_ update: Update) -> AppState {self}
    mutating func update(_ update: Update) {}
    
    enum Update {
        case users(UpsertDelete<User>)
        case todos(UpsertDelete<Todo>)
    }
    
    func update(_ update: Update) -> AppState {
        switch update {
        case .users(let cmd): return handle(cmd)
        case .todos(let cmd): return handle(cmd)
        }
    }
    
    func handle(_ command: UpsertDelete<User>) -> Self {
        var copy = self
        switch command {
        case .upsert(let user): copy.users[user.id] = user
        case .delete(let user): copy.users[user.id] = nil
        }
        return copy
    }
    
    func handle(_ command: UpsertDelete<Todo>) -> Self {
        var copy = self
        switch command {
        case .upsert(let todo): copy.todos[todo.id] = todo
        case .delete(let todo): copy.users[todo.id] = nil
        }
        return copy
    }
}

