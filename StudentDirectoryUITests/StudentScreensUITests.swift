import XCTest

final class StudentScreensUITests: XCTestCase {
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

    func testListShowsStudents() {
        let list = app.tables["studentList"]

        XCTAssertTrue(list.waitForExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars["Students"].exists)
        XCTAssertTrue(cell("01").exists)
        XCTAssertTrue(list.staticTexts["Ada Lovelace"].exists)
    }

    func testTapOnCellOpensDetailsAndBackReturns() {
        XCTAssertTrue(cell("01").waitForExistence(timeout: 10))
        cell("01").tap()

        let details = app.otherElements["studentDetails"]
        XCTAssertTrue(details.waitForExistence(timeout: 5))
        XCTAssertTrue(details.staticTexts["Age: 20"].exists)
        XCTAssertTrue(details.staticTexts["Scholarship: Yes"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.tables["studentList"].waitForExistence(timeout: 5))
    }

    func testSubjectButtonShowsOnlyStudentsOfThisSubject() {
        XCTAssertTrue(cell("02").waitForExistence(timeout: 10))
        cell("02").tap()

        let physics = app.buttons["subjectButton.Physics"]
        XCTAssertTrue(physics.waitForExistence(timeout: 5))
        physics.tap()

        XCTAssertTrue(cell("04").waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars.staticTexts["Physics"].exists)
        let list = app.tables["studentList"]
        XCTAssertEqual(list.cells.count, 4)
        for number in ["02", "04", "06", "10"] {
            XCTAssertTrue(cell(number).exists)
        }
        XCTAssertFalse(cell("01").exists)
    }
}
