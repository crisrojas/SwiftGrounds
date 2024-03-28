//
//  Database.swift
//  PlaygroundsTests
//
//  Created by Cristian Felipe Patiño Rojas on 13/12/2023.
//

import Foundation
fileprivate protocol Persistable: Identifiable, Codable {
    var id: UUID {get}
}

fileprivate class Database {
    private lazy var storage: [UUID: Data] = readFile() {didSet{try?persist()}}
    
    fileprivate let decoder = JSONDecoder()
    fileprivate let encoder = JSONEncoder()
    fileprivate let manager = FileManager.default
    
    let path: String
    
    init(path: String, ext: String = ".json") {
        self.path = path + ext
    }
}

// MARK: - API
extension Database {
    func read<T: Persistable>(id: UUID) -> T? {
        guard let data = storage[id] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func read<T: Persistable>() -> [T] {
        storage.compactMap { (_, data) in
            try? decoder.decode(T.self, from: data)
        }
    }
    
    func upsert<T: Persistable>(_ item: T) throws {
        let data = try encoder.encode(item)
        storage[item.id] = data
    }

    func delete<T: Persistable>(_ item: T) {
        storage[item.id] = nil
    }
    
    @discardableResult
    func deleteAll<T: Persistable>() -> [T] {
        (read() as [T]).forEach {
            storage[$0.id] = nil
        }
        return []
    }
}

// MARK: - File handling

extension Database {
    
    fileprivate func persist() throws {
        let data = try encoder.encode(storage)
        try data.write(to: fileURL(path: path))
    }
    
    fileprivate func readFile() -> [UUID: Data] {
        (try? decoder.decode([UUID:Data].self, from: try Data(contentsOf: fileURL(path: path)))) ?? [:]
    }
    
    fileprivate func fileURL(path: String) throws -> URL {
        try manager
            .url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
    
    public func destroy() throws {
        do {
            try manager.removeItem(atPath: fileURL(path: path).path)
        } catch {
            /// Error == 4 means we can destroy because the file doesn't exist.
            /// We want to ignore that case when trying to destroy the db, specially during test teardown
            guard (error as NSError).code != 4 else {
                return
            }
            throw error
        }
    }
}

import SwiftUI

fileprivate final class DatabaseTests: XCTestCase {
    
    struct Todo: Persistable, Equatable {
        let id: UUID
        var name: String
        
        init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }
    
    var db: Database!
    
//  override func setUp() {
//      db = .init(path: "tests")
//  }
    
//  override func tearDownWithError() throws {
//        try db.destroy()
//  }
    
    func test_create() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }
    
    func test_read() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let items: [Todo] = db.read()
        XCTAssertEqual(items, [todo])
    }
    
    func test_readItem() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }
    
    func test_update() throws {
        var todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        var item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make coffee")
        todo.name = "Make 20 coffees"
        try db.upsert(todo)
        item = db.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make 20 coffees")
    }
    
    func test_delete() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        db.delete(todo)
        let item: Todo? = db.read(id: todo.id)
//      XCTAssertNil(item)
    }
    
    func test_delete_all() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let _: [Todo] = db.deleteAll()
        let item: Todo? = db.read(id: todo.id)
//      XCTAssertNil(item)
    }

    lazy var database = Database(path: "tests-bis")
    
    fileprivate lazy var rud: RUD<Todo> = RUD(
        upsert: database.upsert,
        read: database.read,
        readid: database.read(id:),
        delete: database.delete(_:)
    )
    
   
    struct TodoFeature: View {
        let todos: [Todo]
        fileprivate var rud: RUD<Todo>?
        var body: some View {
            List(todos) { item in
                NavigationLink {
                    TodoDetail(item: item, updateAction: rud?.upsert)
                } label: {
                    Text(item.name)
                }
            }
            .toolbar {
                NavigationLink {
                    TodoCreate(action: rud?.upsert)
                } label: {
                    Text("+")
                }

            }
        }
    }
    
    struct TodoDetail: View {
        @State var item: Todo
        let updateAction: ((Todo) throws -> Void)?
        var body: some View {
            VStack {
                TextField(item.name, text: $item.name)
                
                Button("Edit") {
                   try? updateAction?(item)
                }
            }
        }
    }
    
    struct TodoCreate: View {
        let action: ((Todo) throws -> Void)?
        var body: some View {
            Text("Create")
        }
    }
}


/// Read - Update - Delete methods holder
fileprivate final class RUD<T: Persistable> {
    let read  : ( )  -> [T]
    let readid: (UUID) -> T?
    let upsert: (T) throws -> Void
    let delete: (T) -> Void
    
    init(
        upsert: @escaping (T) throws -> Void,
        read: @escaping () -> [T],
        readid: @escaping (UUID) -> T?,
        delete: @escaping (T) -> Void
    ) {
        self.upsert = upsert
        self.read = read
        self.readid = readid
        self.delete = delete
    }
}

// tests
import Foundation

protocol XCTestCase: AnyObject {}
extension XCTestCase {
    func run() {callAllVoidMethods(from: self)}
}

func callAllVoidMethods(from object: AnyObject) {
    var count: UInt32 = 0
    let methods = class_copyMethodList(type(of: object), &count)
    
    for i in 0..<Int(count) {
        let method = methods![i]
        let selector = method_getName(method)
        if method_getNumberOfArguments(method) == 2 {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector) -> Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(object, selector)
        }
    }
    
    free(methods)
}


struct XCTAssertEqual<T: Equatable> {
    @discardableResult
    init(_ f: T, _ s: T, line: UInt = #line) {
        let result = f == s ? "✅" : "❌"
        print(line.description + " " + result + " " + (f == s).description)
    }
}
