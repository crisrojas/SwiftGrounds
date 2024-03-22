import Foundation


enum MyApi {
	static let environment = ApiEnvironment.dev
	case refreshToken(RefreshAuthCommand)
	case getSomeResource
}


extension MyApi: TargetType {
	var baseURL: URL {Self.environment.url}
	
	var path: String {
		switch self {
			case .refreshToken: return "/token"
			case .getSomeResource: return "/someResource"
		}
	}
	
	var method: Method {
		switch self {
			case .refreshToken: return .put
			case .getSomeResource: return .get
		}
	}
	
	var sampleData: Data { Data() }
	
	var task: Task {
		switch self {
			case .refreshToken(let cmd): return .requestJSONEncodable(cmd)
			case .getSomeResource: return .requestPlain
		}
	}
	
	var headers: [String: String]? {
		let v = "application/json;version=\(Self.environment.apiVersion)"
		return [
			"Content-Type": v,
			"Accept"      : v
		]
	}
	
	var authorizationType: AuthorizationType? {
		switch self {
		default: return .bearer
		}
	}
}

typealias Completion<T> = (Result<T, Error>) -> Void

protocol MyApiProtocol: AnyObject {
	func getSomeResource(onDone: @escaping Completion<SomeResource>)
}

extension Provider: MyApiProtocol where Target == MyApi {
	func getSomeResource(onDone: @escaping Completion<SomeResource>) {
		requestWithAuth(.getSomeResource, onDone: onDone)
	}
}

extension Provider where Target == MyApi {
	func requestWithAuth<T: Decodable>(_ target: MyApi, onDone: @escaping Completion<T>) {
		request(target) { [weak self] result in
			switch result {
				case .success(let response): 
				
				switch response.status {
					case .forbidden: 
						self?.logout()
					case .unauhorized: 
						self?.refreshToken(target, onDone: onDone)
					default: break
				}
				
				case .failure(_): break
			}
		}
	}
	
	func logout() {
		// clear tokens
		// logout
	}
	
	func refreshToken<T: Decodable>(_ target: MyApi, onDone: @escaping Completion<T>) {
		
		// Si estamos refrescando el token
		if settings.refreshingToken {
			// Esperamos a que el token termine de ser refrescado
			if !settings.refreshingToken {
				requestWithAuth(target, onDone: onDone)
			}
		} else {
			settings.refreshingToken = true
			guard let token = storage.refreshToken else {
				logout()
				// @todo: complete onDone with error
				return 
			}
			
			// Refrescamos token
			let cmd = RefreshAuthCommand(token: token)
			request(.refreshToken(cmd)) { [weak self] result in
				guard let self else {return}
				let r: Result<AuthToken, Error> = result.mapResponse()
				
				
				switch r {
					case .success(let authToken): break
					storage.saveTokens(authToken)
					settings.refreshingToken = false
					self.requestWithAuth(target, onDone: onDone)
					case .failure:
						self.logout()
				}
			}
		}
		// Should retry call
		requestWithAuth(target, onDone: onDone)
	}
	
}

extension Result where Success == Response {
	func mapResponse<T: Decodable>() -> Result<T, Error> {
		.failure(NSError(domain: "", code: 0))
	}
}