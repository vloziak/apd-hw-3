import UIKit
import SnapKit

final class StudentListViewController: UIViewController {
    private let store: StudentStore
    private let subject: String?
    private let tableView = UITableView()

    private var students: [Student] {
        if let subject {
            return store.students(matchingSubject: subject)
        }
        return store.students
    }

    init(store: StudentStore, subject: String? = nil) {
        self.store = store
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = subject ?? "Students"
        setupTableView()
        if subject == nil {
            setupAddButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(StudentCell.self, forCellReuseIdentifier: StudentCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.accessibilityIdentifier = "studentList"
    }
    
    private func setupAddButton() {
        let addItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in
                self?.showAddForm()
            }
        )
        addItem.accessibilityIdentifier = "addStudentButton"
        addItem.accessibilityLabel = "Add student"
        navigationItem.rightBarButtonItem = addItem
    }
    
    private func showAddForm() {
        let formController = StudentFormViewController(store: store) { [weak self] in
            self?.tableView.reloadData()
        }
        present(UINavigationController(rootViewController: formController), animated: true)
    }
}

extension StudentListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        students.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StudentCell.reuseIdentifier,
            for: indexPath
        ) as? StudentCell else {
            return UITableViewCell()
        }
        cell.configure(with: students[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        guard editingStyle == .delete else { return }
        let student = students[indexPath.row]
        do {
            try store.deleteStudent(id: student.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as StudentStoreError {
            showErrorAlert(message: error.message)
        } catch {
            showErrorAlert(message: "Something went wrong. Please try again.")
        }
    }
}

extension StudentListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let student = students[indexPath.row]
        let detailController = StudentDetailViewController(store: store, studentID: student.id)
        navigationController?.pushViewController(detailController, animated: true)
    }
}
