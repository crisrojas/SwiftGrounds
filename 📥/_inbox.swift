

struct Primitives {
	let int: Int
	let double: Double
	let string: String
	let bool: Bool
}


func getDummy<T>() -> T {fatalError("")}

func main(){
	_ = Primitives(
		int: getDummy(),
		double: getDummy(), 
		string: getDummy(),
		bool: getDummy()
	)
}

import SwiftUI

struct FeatureState {
	var count = 0
}

protocol FeatureProtocol: ObservableObject {
	var state: FeatureState { get }
	func increase()
	func decrease()
}


final class FeatureStore: FeatureProtocol {
	@Published private(set) var state = FeatureState()
	
	func increase() {}
	func decrease() {}
}

let feature = FeatureStore()

struct FeatureView<T: FeatureProtocol>: SwiftUI.View {
	@StateObject var store: T
	var body: some SwiftUI.View {
		HStack {
			Button("-") { store.decrease() }
			Text(store.state.count.description)
			Button("+") { store.increase() }
		}
	}
}


protocol WireframeProtocol {
	func navigateToScreen()
}

final class View {}
final class ViewController: WireframeProtocol {
	lazy var view = View()
	lazy var wirefame: WireframeProtocol = self
	
	func goToScreen() {
		wirefame.navigateToScreen()
	}
	
	func navigateToScreen() {
		print("navigate")
	}
}

final class WirefarmeMock: WireframeProtocol {
	var navigateToScreenCalledCount = 0
	func navigateToScreen() {
		navigateToScreenCalledCount += 1
	}
}
let vc = ViewController()
vc.wirefame = WirefarmeMock()
vc.goToScreen()

/*
dependency.someFuncWithClosure { self in
	self.doSomething()
}
*/