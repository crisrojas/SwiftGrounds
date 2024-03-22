import Foundation

enum ApiEnvironment {
	case prod 
	case staging
	case dev
	
	private var _url: String {
		switch self {
			case .prod: return "https://api.myapi.com"
			case .staging: return "https://staging.myapi.com"
			case .dev: return "https://dev.myapi.com"
		}
	}
	
	var url: URL { URL(string: _url)! }
	
	var clientId: String { 
		switch self {
			case .prod: return "prod_clientId"
			case .staging: return "staging_clientId"
			case .dev: return "dev_clientId"
		}
	}
	
	var clientSecret: String {
		switch self {
			case .prod: return "prod_clientSecret"
			case .staging: return "staging_clientSecret"
			case .dev: return "dev_clientSecret"
		}
	}
	
	var apiVersion: String { "1.0" }
}
