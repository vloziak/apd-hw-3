import UIKit
import SnapKit

final class StudentFormViewController: UIViewController {
    private let store: StudentStore
    private let studentID: UUID?
    private let onSave: () -> Void
    
    private let stack = UIStackView()
    private let nameLabel = UILabel()
    private let nameField = UITextField()
    private let ageLabel = UILabel()
    private let ageField = UITextField()
    
    init(store: StudentStore, studentID: UUID? = nil, onSave: @escaping () -> Void) {
        self.store = store
        self.studentID = studentID
        self.onSave = onSave
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = studentID == nil ? "New Student" : "Edit Student"
        setupNavigation()
        setupViews()
        setupConstraints()
        fillFields()
    }
    
    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        let saveItem = UIBarButtonItem(
            systemItem: .save,
            primaryAction: UIAction { [weak self] _ in
                self?.save()
            }
        )
        saveItem.accessibilityIdentifier = "saveStudentButton"
        navigationItem.rightBarButtonItem = saveItem
    }
    
    private func setupViews() {
        stack.axis = .vertical
        stack.spacing = 8
        
        setup(nameLabel, text: "Name")
        setup(ageLabel, text: "Age")
        
        setup(nameField, label: "Name", placeholder: "Full name", identifier: "studentNameField")
        nameField.autocapitalizationType = .words
        nameField.textContentType = .name
        
        setup(ageField, label: "Age", placeholder: "Age in years", identifier: "studentAgeField")
        ageField.keyboardType = .numberPad
        
        [nameLabel, nameField, ageLabel, ageField].forEach(stack.addArrangedSubview)
        stack.setCustomSpacing(20, after: nameField)
        view.addSubview(stack)
    }
    
    private func setup(_ label: UILabel, text: String) {
        label.text = text
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.isAccessibilityElement = false
    }
    
    private func setup(_ field: UITextField, label: String, placeholder: String, identifier: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.accessibilityIdentifier = identifier
        field.accessibilityLabel = label
    }
    
    private func setupConstraints() {
        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func fillFields() {
        guard let studentID,
              let student = store.students.first(where: { $0.id == studentID }) else { return }
        nameField.text = student.name
        ageField.text = String(student.age)
    }
    
    private func save() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let ageText = (ageField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let age = Int(ageText) else {
            showErrorAlert(message: "Age must be a whole number.")
            return
        }
        
        do {
            if let studentID {
                try store.updateStudent(id: studentID, name: name, age: age)
            } else {
                try store.addStudent(name: name, age: age)
            }
            onSave()
            dismiss(animated: true)
        } catch let error as StudentStoreError {
            showErrorAlert(message: error.message)
        } catch {
            showErrorAlert(message: "Something went wrong. Please try again.")
        }
    }
}
