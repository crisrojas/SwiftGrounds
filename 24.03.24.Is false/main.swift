// Seeking for a better bool semantics
final class MyClass {
    var loading = true
    var opening = false
    var failing = true
}

let myClass = MyClass()

extension Bool {
    var isFalse: Bool { self == false }
}

print(myClass.loading.isFalse)
print(myClass.opening.isFalse)
print(myClass.failing.isFalse)