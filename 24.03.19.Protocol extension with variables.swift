import Foundation
// #pop

protocol SomeProtocol {}


// Gives default value
class TypeErasureImplementation: SomeProtocol { 
    var id = UUID()
}

final class Storage {
    let id: UUID
    lazy var data: [String: Data] = read() { didSet { persist() } }
    func read() -> [String: Data] {fatalError("")}
    func persist() { }
    
    init(id: UUID) { self.id = id }
    
    func get<T>(_ key: String) -> T {fatalError("@todo")}
    func set<T>(_ newValue: T) {fatalError("@todo")}
}

extension SomeProtocol {
    var id: UUID { UUID() }
    private var storage: Storage { Storage(id: id) }
    var some: String {
        get { storage.get("some") }
        set { storage.set(newValue) }
    }
}

struct Implementation: SomeProtocol { }

// ¿Por qué no usar una clase directamente?
final class ClassImplementation: TypeErasureImplementation { }



import ObjectiveC.runtime

protocol Identifiable: AnyObject {
    var name: String { get set }
}

var IdentifiableIdKey   = "kIdentifiableIdKey"
var IdentifiableNameKey = "kIdentifiableNameKey"

fileprivate var identifiableProtocolLock = NSLock()
// https://stackoverflow.com/questions/38885622/swift-protocol-extensions-property-default-values

extension Identifiable {
        
    var name: String {
        get {
            identifiableProtocolLock.lock()
            defer { identifiableProtocolLock.unlock() }
            return (objc_getAssociatedObject(self, &IdentifiableNameKey) as? String) ?? "default"
        }
        set {
            identifiableProtocolLock.lock()
            defer { identifiableProtocolLock.unlock() }
            objc_setAssociatedObject(self, &IdentifiableNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }   
    }
}

class A: Identifiable {}

var a = A()
print(a.name)  // default

let queue = DispatchQueue(label: "com.example.counterQueue", attributes: .concurrent)

// Incrementar el contador 1000 veces en múltiples hilos simultáneamente
for int in 0..<1000 {
    queue.async {
        a.name += int.description
    }
}

sleep(1)
print(a.name)