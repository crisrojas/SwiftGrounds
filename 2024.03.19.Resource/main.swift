// #reactivity #uikit

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(String? = nil)
    
    
    var isIdle: Bool {
        if case .idle = self {return true}
        return false
    }
    
    var isLoading: Bool {
        if case .loading = self {return true}
        return false
    }
    
    var isSuccess: Bool {
        if case .success = self {return true}
        return false
    }
    
    var isError: Bool {
        if case .idle = self {return true}
        return false
    }
    
    var data: T? {
        if case let .success(data) = self { return data }
        return nil
    }
    
    mutating func update(from result: Result<T, Error>) {
        self = .init(from: result)
    }
    
    init(from result: Result<T, Error>) {
        switch result {
            case .success(let t): self = .success(t)
            case .failure(let error): self = .error(error.localizedDescription)
        }
    }
}

typealias Outcome<T> = Result<T, Error>
typealias OutcomeCompletion<T> = (Outcome<T>) -> Void

enum JSON {case empty}
final class Resource {
    
    // This could use a Codable object instead of JSON:
    // `final class Resource<T: Codable> { ...  }`
    // `state: ViewState<T>`
    // But for demo purposes, lets use a basic JSON structure
    var state: ViewState<JSON> = .idle {
        didSet { callbacks.forEach { $0(state) } }
    }
    
    var callbacks = [(ViewState<JSON>)->Void]()
    let path: String
    init(_ p: String) { path = p }
    
    func fetch() {
        state = .loading
        // Here would go the async fetch (dispatchQueue, combine, async/await etc...)
        state.update(from: .success(.empty))
    }
    // A resource represents a collection of entities from the data api
    // It should contain generic methods associated to the HTTP verbs:
    func post() {}
    func delete() {}
    func patch() {}
    
    func onChange(_ completion: @escaping (ViewState<JSON>)->Void) { 
        callbacks.append(completion)
    }
}

extension Resource {
    static var profiles = Resource("/profiles")
}

class View {
    var isHidden = false
}

extension View {
    var isVisible: Bool { 
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

final class ProfilesView: View {
    func update(with json: JSON?) {
        guard let json else { return }
        // do something with the json
    }
}

final class ErrorView: View {}
final class ActivityIndicator: View {}


final class ProfilesViewController {
    
    // Views
    lazy var profilesView = ProfilesView()
    lazy var indicator   = ActivityIndicator()
    lazy var errorView   = ErrorView()
    
    // States
    var resource = Resource.profiles
    
    func setInitialStates() {
        profilesView.isHidden = true
        indicator.isHidden   = true
        errorView.isHidden   = true
    }
    
    func startObservingResource() {
        resource.onChange(updateUI)
    }
    
    func updateUI(state: ViewState<JSON>) { 
        indicator.isVisible   = state.isLoading
        profilesView.isVisible = state.isSuccess
        errorView.isVisible   = state.isError
        profilesView.update(with: state.data)
    }
    
    func fetchProfiles() {
        resource.fetch()
    }
}


final class AnotherViewController {
    var resource = Resource.profiles
    
    var label = UILabel()
    
    func setInitialStates() {
        label.text = "No resource found"
    }
    
    func viewDidLoad() {
        resource.onChange(updateUI)
    }
    
    func updateUI(state: ViewState<JSON>) {
        if state.isSuccess {
            label.text = "Resource has been fetched!"
        }
    }
}

protocol ResourceObserver {
    var resource: Resource { get set }
    func updateUI(state: ViewState<JSON>)
    func setInitialStates()
}

extension ResourceObserver {
    func startObservingResource() {
        resource.onChange(updateUI)
    }
}

extension ProfilesViewController: ResourceObserver {}
extension AnotherViewController: ResourceObserver {}

describe("Test resource observation works") {
    given("a resource shared among two viewControllers") {
        
        var resource = Resource("/profiles")
        var profilesVC = ProfilesViewController()
        var anotherVC = AnotherViewController()
        profilesVC.resource = resource
        anotherVC.resource = resource
        
        when("both start monitoring resource") {
            profilesVC.startObservingResource()
            anotherVC.startObservingResource()
            
            and("they have a default initial states") {
                
                anotherVC.setInitialStates()
                profilesVC.setInitialStates()
                
                expect(profilesVC.profilesView.isHidden).toBe(true)
                expect(anotherVC.label.text).toBe(equalTo("No resource found"))
                
                when("one of them fetches/updates the resource") {
                    profilesVC.fetchProfiles()
                    
                    then("both view controllers states are updated") {
                        expect(profilesVC.indicator.isHidden).toBe(true)
                        expect(profilesVC.profilesView.isHidden).toBe(false)
                        expect(anotherVC.label.text).toBe(equalTo("Resource has been fetched!"))
                    }
                }
            }
        }
    }
}


