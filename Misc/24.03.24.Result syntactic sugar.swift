
typealias Result<T> = Swift.Result<T, Error>
typealias Completion<T> = (Result<T>) -> Void

extension Result {
	var data: Success? {
		if case let .success(data) = self { return data }
		return nil
	}
}

func doSomething(onDone: Completion<String>) {
	onDone(.success("Done"))
}

doSomething { result in
	print(result.data!)
}
