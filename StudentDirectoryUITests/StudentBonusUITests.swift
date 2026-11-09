import XCTest

final class StudentBonusUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func cell(_ number: String) -> XCUIElement {
        app.cells["studentCell.00000000-0000-0000-0000-0000000000\(number)"]
    }

    private func waitUntilGone(_ element: XCUIElement) {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: 5), .completed)
    }

    func testAddRejectsZeroAgeThenAddsStudent() {
        let addButton = app.buttons["addStudentButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10))
        addButton.tap()

        let name = app.textFields["studentNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Linus Torvalds")
        let age = app.textFields["studentAgeField"]
        age.tap()
        age.typeText("0")
        app.buttons["saveStudentButton"].tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertTrue(alert.staticTexts["Age must be greater than 0."].exists)
        alert.buttons["OK"].tap()

        age.tap()
        age.typeText("5")
        app.buttons["saveStudentButton"].tap()

        let list = app.tables["studentList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        list.swipeUp()
        list.swipeUp()
        XCTAssertTrue(list.staticTexts["Linus Torvalds"].waitForExistence(timeout: 5))
        XCTAssertEqual(list.cells.count, 11)
    }

    func testEditChangesNameOnDetailsAndList() {
        XCTAssertTrue(cell("01").waitForExistence(timeout: 10))
        cell("01").tap()
        let editButton = app.buttons["editStudentButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5))
        editButton.tap()

        let name = app.textFields["studentNameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        let oldName = name.value as? String ?? ""
        XCTAssertEqual(oldName, "Ada Lovelace")
        name.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: oldName.count))
        name.typeText("Ada King")
        app.buttons["saveStudentButton"].tap()

        XCTAssertTrue(app.otherElements["studentDetails"].staticTexts["Ada King"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.tables["studentList"].staticTexts["Ada King"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.tables["studentList"].staticTexts["Ada Lovelace"].exists)
    }

    func testSwipeDeletesStudent() {
        let alan = cell("02")
        XCTAssertTrue(alan.waitForExistence(timeout: 10))

        alan.swipeLeft()
        let deleteButton = app.buttons["Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()

        waitUntilGone(alan)
        XCTAssertEqual(app.tables["studentList"].cells.count, 9)
    }
}
