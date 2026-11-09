import UIKit
import SnapKit

final class StudentCell: UITableViewCell {
    static let reuseIdentifier = "StudentCell"

    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let detailsLabel = UILabel()
    private let scholarshipLabel = UILabel()
    private let textStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
    }

    func configure(with student: Student) {
        nameLabel.text = student.name
        let grade = String(format: "%.1f", student.averageGrade)
        detailsLabel.text = "Age \(student.age) · Grade \(grade)"
        scholarshipLabel.text = student.isScholarshipHolder ? "Scholarship holder" : "No scholarship"
        avatarImageView.image = UIImage(named: student.avatarName) ?? UIImage(named: "avatar-default")

        accessibilityIdentifier = "studentCell.\(student.id.uuidString)"
        accessibilityLabel = "\(student.name), age \(student.age), grade \(grade), "
            + (student.isScholarshipHolder ? "scholarship holder" : "no scholarship")
    }

    private func setupViews() {
        accessoryType = .disclosureIndicator
        isAccessibilityElement = true
        accessibilityTraits = .button

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 28

        setup(nameLabel, style: .headline, color: .label)
        setup(detailsLabel, style: .subheadline, color: .secondaryLabel)
        setup(scholarshipLabel, style: .footnote, color: .secondaryLabel)

        textStack.axis = .vertical
        textStack.spacing = 4
        [nameLabel, detailsLabel, scholarshipLabel].forEach(textStack.addArrangedSubview)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(textStack)
    }

    private func setup(_ label: UILabel, style: UIFont.TextStyle, color: UIColor) {
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = color
    }

    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide)
            make.centerY.equalToSuperview()
            make.size.equalTo(56)
            make.top.greaterThanOrEqualTo(contentView.layoutMarginsGuide)
            make.bottom.lessThanOrEqualTo(contentView.layoutMarginsGuide)
        }
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.top.bottom.equalTo(contentView.layoutMarginsGuide)
        }
    }
}
