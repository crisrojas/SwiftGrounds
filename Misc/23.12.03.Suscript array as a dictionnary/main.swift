import Foundation

// The goal of this playground is to create a suscript that allows consume an array as it was a dictionnary
// This gives us dictionnary api ergonomics for manipulating the array contents
//
// For example, appending an itme would be as easy as doing:
//
// array[item.id] = item
//
// And deleting it:
//
// array[item.id] = nil // deletes item

// We will need to conform to Identifiable
extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        get {
            return first { $0.id == id }
        }
        set(newValue) {
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}

struct User: Identifiable, Equatable {
    var id = UUID()
    var firstName: String
    var lastName: String
}

final class ArraySubscriptTests {
    @objc func tests_create() {
        let user = User(firstName: "Cristian", lastName: "Patiño")
        var sut = [User]()
        sut[user.id] = user
        expect(sut[user.id]?.firstName).toBe(equalTo("Cristian"))
    }
    
    @objc func tests_update() {
        var user = User(firstName: "Cristian", lastName: "Patiño")
        var sut = [User]()
        sut[user.id] = user
        
        // Update
        user.firstName = "Cristian Felipe"
        sut[user.id] = user
        
        expect(sut[user.id]?.firstName).toBe(equalTo("Cristian Felipe"))
    }
    
    @objc func test_delete() {
        let user = User(firstName: "Cristian", lastName: "Patiño")
        var sut = [User]()
        sut[user.id] = user
        expect(sut[user.id]).toBe(differentFrom(nil))
        sut[user.id] = nil
        expect(sut[user.id]).toBe(equalTo(nil))
    }
}

runAll(ArraySubscriptTests())