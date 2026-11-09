import XCTest
@testable import StudentDirectory

@MainActor
final class StudentStoreTests: XCTestCase {
    private var store: StudentStore!

    override func setUp() {
        super.setUp()
        store = StudentStore()
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    func testSubjectFilterReturnsStudentsInStoreOrder() {
        let names = store.students(matchingSubject: "Algorithms").map(\.name)

        XCTAssertEqual(names, ["Ada Lovelace", "Alan Turing", "Grace Hopper", "Edsger Dijkstra", "Donald Knuth"])
    }

    func testSubjectFilterIsCaseSensitiveAndUnknownSubjectIsEmpty() {
        XCTAssertTrue(store.students(matchingSubject: "math").isEmpty)
        XCTAssertTrue(store.students(matchingSubject: "Chemistry").isEmpty)
        XCTAssertEqual(store.students(matchingSubject: "Math").count, 3)
    }

    func testAddStudentUsesDefaultValues() throws {
        try store.addStudent(name: "Linus Torvalds", age: 19)

        XCTAssertEqual(store.students.count, 11)
        let student = try XCTUnwrap(store.students.last)
        XCTAssertEqual(student.name, "Linus Torvalds")
        XCTAssertEqual(student.age, 19)
        XCTAssertEqual(student.averageGrade, 0)
        XCTAssertFalse(student.isScholarshipHolder)
        XCTAssertTrue(student.subjects.isEmpty)
        XCTAssertEqual(student.avatarName, "avatar-default")
        XCTAssertFalse(StudentSeedData.students.contains { $0.id == student.id })
    }

    func testInvalidInputThrowsAndDoesNotChangeStore() {
        let before = store.students
        let adaID = before[0].id

        XCTAssertThrowsError(try store.addStudent(name: "", age: 20)) { error in
            XCTAssertEqual(error as? StudentStoreError, .blankName)
        }
        XCTAssertThrowsError(try store.addStudent(name: "   ", age: 20)) { error in
            XCTAssertEqual(error as? StudentStoreError, .blankName)
        }
        XCTAssertThrowsError(try store.addStudent(name: "Linus", age: 0)) { error in
            XCTAssertEqual(error as? StudentStoreError, .nonPositiveAge)
        }
        XCTAssertThrowsError(try store.updateStudent(id: adaID, name: "Ada", age: -1)) { error in
            XCTAssertEqual(error as? StudentStoreError, .nonPositiveAge)
        }

        XCTAssertEqual(store.students, before)
    }

    func testUpdateChangesOnlyNameAndAge() throws {
        let original = store.students[0]

        try store.updateStudent(id: original.id, name: "Ada King", age: 28)

        var expected = original
        expected.name = "Ada King"
        expected.age = 28
        XCTAssertEqual(store.students[0], expected)
        XCTAssertEqual(store.students.count, 10)
    }

    func testDeleteRemovesStudentAndUnknownIDThrows() throws {
        let alan = store.students[1]

        try store.deleteStudent(id: alan.id)

        XCTAssertEqual(store.students.count, 9)
        XCTAssertFalse(store.students.contains { $0.id == alan.id })
        XCTAssertTrue(store.students(matchingSubject: "Physics").allSatisfy { $0.id != alan.id })

        let before = store.students
        XCTAssertThrowsError(try store.deleteStudent(id: alan.id)) { error in
            XCTAssertEqual(error as? StudentStoreError, .unknownID(alan.id))
        }
        XCTAssertThrowsError(try store.updateStudent(id: alan.id, name: "Alan", age: 21)) { error in
            XCTAssertEqual(error as? StudentStoreError, .unknownID(alan.id))
        }
        XCTAssertEqual(store.students, before)
    }
}
