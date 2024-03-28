import Foundation


struct Ingredient {
	let id: UUID
	let name: String
	
	init(name: String) {
		id = UUID()
		self.name = name
	}
}

struct ShoppingList { 
	let id: UUID
	var ingredients: [Ingredient]
	var updatedAt: Date
}

func makeInitialServerData() -> ShoppingList {
	let id = UUID()
	let ingredients = ["chicken", "tomato", "carot"].map { Ingredient(name: $0) }
	return ShoppingList(id: id, ingredients: ingredients, updatedAt: Date())
}

var serverData = makeInitialServerData()

final class Reachability {
	var isReachable = false {
		didSet { notify() }
	}
	
	var observers = [(Bool) ->Void]()
	
	func notify() {
		observers.forEach { $0(isReachable) }
	}
	
	func addObserver(block: @escaping (Bool) -> Void) {
		observers.append(block)
	}
}

final class MyApp {
	
	var data: ShoppingList?
	let reachability = Reachability()
	
	func appDidLoad() {
		startObserving()
		retrieveData()
	}
	
	func retrieveData() {
		data = serverData
	}
	
	func fetchData() -> ShoppingList {
		serverData
	}
	
	func addIngredient(name: String) {
		print("\nAdding ingredient with reachability: \(reachability.isReachable)...")
		let ingredient = Ingredient(name: name)
		let updateDate = Date()
		if reachability.isReachable {
			serverData.ingredients.append(ingredient)
			data?.ingredients.append(ingredient)
			data?.updatedAt = updateDate
		} else {
			data?.ingredients.append(ingredient)
			data?.updatedAt = updateDate
		}
	}
	
	func startObserving() {
		reachability.addObserver { [weak self] isReachable in 
			guard let self, let data = self.data else { return }
			if isReachable {
				let serverData = self.fetchData()
				
				if serverData.updatedAt < data.updatedAt {
					// what if serverData.updatedAt < data.updatedAt
					// but server has new newIngredients that were added a bit before from another device ? ...
					self.patch(with: data)
					return
				}
				
				if serverData.updatedAt > data.updatedAt {
					
				}
			}
		}
	}
	
	func patch(with data: ShoppingList) {
		serverData = data
	}
}



let app = MyApp()

// for debug purposes
func getAppIngredientNames() -> [String] {
	app.data?.ingredients.map {$0.name} ?? []
}

func getServerIngredientNames() -> [String] {
	serverData.ingredients.map {$0.name}
}

app.appDidLoad()

app.addIngredient(name: "onion")

print("Ingredients on db:")
dump(getAppIngredientNames())
print(app.data!.updatedAt)

print("\nIngredients on server before regaining network:")
dump(getServerIngredientNames())

print("\nMaking network reachable...")
app.reachability.isReachable = true
dump(getServerIngredientNames())