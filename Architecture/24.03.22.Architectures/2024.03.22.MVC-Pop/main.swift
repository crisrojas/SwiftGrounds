final class ErrorView: UIView {}

final class View {
    
    var state = State<String>.idle {
        didSet {updateUI()}
    }
    
    lazy var label     = Label()
    lazy var indicator = Indicator()
    lazy var errorView = ErrorView()
    
    func updateUI() {
        label.isVisible = state.isSuccess
        indicator.isVisible = state.isLoading
        errorView.isVisible = state.isError
        label.text = state.data
    }
}


final class ViewController {
    lazy var view = View()
        
    func viewDidLoad() {
        fetchData { [weak self] in
            self?.view.state = .init(from: $0)
        }
    }
}

// Dependency injection through protocol conformance + default protocol implementation
protocol Service {}

extension Service {
    func fetchData(completion: @escaping (Result<String, Error>) -> Void) {
        completion(.success("success!"))
    }
}

extension ViewController: Service {}