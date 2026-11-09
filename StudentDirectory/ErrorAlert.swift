import UIKit

extension StudentStoreError {
    var message: String {
        switch self {
        case .blankName:
            return "Name can't be empty."
        case .nonPositiveAge:
            return "Age must be greater than 0."
        case .unknownID:
            return "This student doesn't exist anymore."
        }
    }
}

extension UIViewController {
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Can't save changes", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
