
class UIView {
    var isHidden = false
}

extension UIView {
    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

class Label: UIView {
    var text: String?
}

class Button: UIView { }
class Indicator: UIView {}