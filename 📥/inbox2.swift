
final class Store {}

protocol Feature {
	var store: Store? { get }
	func handle(_ message: Core.Message)
}

protocol UseCase {
	var store: Store { get }
}

final class TodoFeature: Feature {
	var store: Store?
	func handle(_ message: Core.Message) {
		
	}
}

final class Core {
	var store: Store?
	lazy var features: [any Feature] = [
		TodoFeature()
	].map { 
		$0.store = store
		return $0
	}
	
	enum UD<T> {
		case upsert
		case delete
	}
	
	struct Todo {}
	
	enum Message {
		case handleTodos(UD<Todo>)
	}
	
	func handle(_ message: Message) {
		features.forEach { 
			$0.handle(message)
		}
	}
}

