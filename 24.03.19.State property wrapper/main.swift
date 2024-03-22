// #reactivity #oservable #swiftui
import Foundation

// This is an attempt to come up with a similar reactivity pattern to the one use it on SwiftUI.
// Heavily inspired by the [Tx](https://github.com/swift2931/Tx) mini library of Jim Lai
@propertyWrapper
class State<T> {
    var wrappedValue: T {
        didSet { notifyObservers() }
    }
    
    private var callbacks = [(T) -> Void]()
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    
    init(_ value: T) {
        wrappedValue = value
    }
    
    func addObserver(_ callback: @escaping (T) -> Void) {
        callbacks.append(callback)
    }
    
    func addObserver<O>(_ keyPath: KeyPath<T, O>, _ callback: @escaping (O) -> Void) {
        addObserver { newValue in
            callback(newValue[keyPath: keyPath])
        }
    }
    
    private func notifyObservers() {
        callbacks.forEach { $0(wrappedValue) }
    }
}

protocol Textable: AnyObject {
    var text: String? { get set }
}


extension UILabel {
    func bindTo<T>(_ keyPath: KeyPath<T, String>, on state: State<T>) { 
        state.addObserver(keyPath) { [weak self] newValue in
            self?.text = newValue
        }
    }
    
    func bindTo(_ state: State<String>) {
        state.addObserver() { [weak self] newValue in
            self?.text = newValue
        }
    }
}

/* 
@todo: 
- Two way binding...
- Computed variables
*/
describe("State binding works") {
    
    given("a label and stateful object") {
        struct Object {
            var value = "some value"
        }
        
        var label = UILabel()
        var object = State(Object())
        
        when("binding label with a value of the object") {
            label.bindTo(\.value, on: object)
            
            and("updating object value") {
                object.wrappedValue.value = "new value"
                
                then("label text is updated") {
                    expect(label.text).toBe(equalTo("new value"))
                }
            }
        }
        
    }
}


