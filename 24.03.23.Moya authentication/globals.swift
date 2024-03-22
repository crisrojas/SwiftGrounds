final class Storage {
	var refreshToken: String?
	var accessToken: String?
	
	func saveTokens(_ authToken: AuthToken) {
		// you may want to encrypt those values
		refreshToken = authToken.refreshToken
		accessToken =  authToken.accessToken
	}
}

final class Settings {
	var refreshingToken = false
}


var settings = Settings()
var storage = Storage()