/*
	(Failed) Attempt to create a syntactic sugar so we don't have to type much when declaring optional closures.
	
	Instead of:
	
	`var someVar: ((SomeType) -> Void)?`
	
	We should be able to write:
	
	`var someVar: SomeType.Void?`
	
	Probably not useful at all ... still fun to implement!
*/

enum _Async<T> {
	enum Throws {
		typealias Void = (T) async throws -> Swift.Void
		
		typealias Same  =  (Self) async throws -> Self
		// Swift Primitives
		typealias String = (Self) async throws -> Swift.String
		typealias Int    = (Self) async throws -> Swift.Int
		typealias Double = (Self) async throws -> Swift.Double
		typealias Bool   = (Self) async throws -> Swift.Bool
		
		// Custom type
		typealias Returns<T> = (T) async throws -> T
	}
	
	typealias Void = (T) async -> Swift.Void
	
	typealias Same  =  (Self) async -> Self
	// Swift Primitives
	typealias String = (Self) async -> Swift.String
	typealias Int    = (Self) async -> Swift.Int
	typealias Double = (Self) async -> Swift.Double
	typealias Bool   = (Self) async -> Swift.Bool
	
	// Custom type
	typealias Returns<T> = (T) async -> T
}

enum _Throws<T> {
	typealias Void = (T) throws -> Swift.Void

	typealias Same  =  (Self) throws -> Self
	// Swift Primitives
	typealias String = (Self) throws -> Swift.String
	typealias Int    = (Self) throws -> Swift.Int
	typealias Double = (Self) throws -> Swift.Double
	typealias Bool   = (Self) throws -> Swift.Bool
	
	// Custom type
	typealias Returns<T> = (T) throws -> T
}

protocol Voidable {}

extension Voidable {
	typealias Void = (Self) -> Swift.Void
	typealias Async = _Async<Self>
	typealias Throws = _Throws<Self>
	
	typealias Same  =  (Self) -> Self
	// Swift Primitives
	typealias String = (Self) -> Swift.String
	typealias Int    = (Self) -> Swift.Int
	typealias Double = (Self) -> Swift.Double
	typealias Bool   = (Self) -> Swift.Bool
	
	// Custom type
	typealias Returns<T> = (Self) -> T
}

extension Int: Voidable {}
extension Double: Voidable {}
extension String: Voidable {}
extension Bool: Voidable {}

final class Example {
	// sync
	var getCount: String.Int?
	var greet: String.Same?
	
	var ex1: String.Void?
	var ex2: String.Throws.Void?
	var ex3: String.Throws.String?
	
	// async
	var ex4: String.Async.Void?
	var ex5: String.Async.String?
	var ex6: String.Async.Throws.String?
	
	struct Object {}
	var ex7: String.Async.Throws.Returns<Object>?
	
	// Swift syntax is actually shorter and more readable:
	var ex8: ((String) async throws -> Object)? 
}

let example = Example()

// Get count
example.getCount = { $0.count }
let count = example.getCount!("this string has 29 characters")
print(count == 28)

// Greet
example.greet = { "hello \($0)" }
print(example.greet!("cristian"))

/*
	Maybe I should check this https://github.com/onmyway133/EasyClosure/tree/master for ideas of a better implementation
*/