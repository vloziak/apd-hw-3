import UIKit
import SnapKit

final class StudentDetailViewController: UIViewController {
    private let store: StudentStore
    private let studentID: UUID

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let ageLabel = UILabel()
    private let gradeLabel = UILabel()
    private let scholarshipLabel = UILabel()
    private let subjectsTitleLabel = UILabel()
    private let subjectsStack = UIStackView()

    private var student: Student? {
        store.students.first { $0.id == studentID }
    }

    init(store: StudentStore, studentID: UUID) {
        self.store = store
        self.studentID = studentID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.accessibilityIdentifier = "studentDetails"
        setupViews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStudent()
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.axis = .vertical
        contentStack.spacing = 12

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 60
        avatarImageView.isAccessibilityElement = false

        let avatarContainer = UIView()
        avatarContainer.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.size.equalTo(120)
        }

        setup(nameLabel, style: .title1, color: .label)
        nameLabel.textAlignment = .center
        setup(idLabel, style: .footnote, color: .secondaryLabel)
        setup(ageLabel, style: .body, color: .label)
        setup(gradeLabel, style: .body, color: .label)
        setup(scholarshipLabel, style: .body, color: .label)
        setup(subjectsTitleLabel, style: .headline, color: .label)
        subjectsTitleLabel.text = "Subjects"
        subjectsTitleLabel.accessibilityTraits = .header

        subjectsStack.axis = .vertical
        subjectsStack.alignment = .leading
        subjectsStack.spacing = 8

        [avatarContainer, nameLabel, idLabel, ageLabel, gradeLabel,
         scholarshipLabel, subjectsTitleLabel, subjectsStack]
            .forEach(contentStack.addArrangedSubview)
        contentStack.setCustomSpacing(24, after: scholarshipLabel)
    }

    private func setup(_ label: UILabel, style: UIFont.TextStyle, color: UIColor) {
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = color
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.width.equalTo(scrollView.frameLayoutGuide).offset(-40)
        }
    }

    private func showStudent() {
        guard let student else { return }

        title = student.name
        avatarImageView.image = UIImage(named: student.avatarName) ?? UIImage(named: "avatar-default")
        nameLabel.text = student.name
        idLabel.text = "ID: \(student.id.uuidString)"
        ageLabel.text = "Age: \(student.age)"
        gradeLabel.text = "Average grade: \(String(format: "%.1f", student.averageGrade))"
        scholarshipLabel.text = "Scholarship: \(student.isScholarshipHolder ? "Yes" : "No")"
        showSubjects(student.subjects)
    }

    private func showSubjects(_ subjects: [String]) {
        subjectsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if subjects.isEmpty {
            let emptyLabel = UILabel()
            setup(emptyLabel, style: .body, color: .secondaryLabel)
            emptyLabel.text = "No subjects"
            subjectsStack.addArrangedSubview(emptyLabel)
            return
        }

        for subject in subjects {
            subjectsStack.addArrangedSubview(makeSubjectButton(for: subject))
        }
    }

    private func makeSubjectButton(for subject: String) -> UIButton {
        var configuration = UIButton.Configuration.tinted()
        configuration.title = subject
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = UIFont.preferredFont(forTextStyle: .body)
            return attributes
        }

        let action = UIAction { [weak self] _ in
            self?.showStudents(studying: subject)
        }
        let button = UIButton(configuration: configuration, primaryAction: action)
        button.accessibilityIdentifier = "subjectButton.\(subject)"
        button.accessibilityHint = "Shows all students who study \(subject)"
        return button
    }

    private func showStudents(studying subject: String) {
        let listController = StudentListViewController(store: store, subject: subject)
        navigationController?.pushViewController(listController, animated: true)
    }
}
