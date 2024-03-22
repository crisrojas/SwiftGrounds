
struct SomeResource: Decodable {}

struct AuthToken: Decodable, Equatable {
	let accessToken: String
	let refreshToken: String
}

// PUT command
struct RefreshAuthCommand: Encodable {
	let refreshToken: String
	let grantType: String
	let clientId: String
	let clientSecret: String
	
	init(token: String) {
		refreshToken = token
		grantType = "refresh_token"
		clientId = MyApi.environment.clientId
		clientSecret = MyApi.environment.clientSecret
	}
}
