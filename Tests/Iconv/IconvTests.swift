import XCTest
@testable import Iconv

class IconvTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        //XCTAssertEqual(Iconv().text, "Hello, World!")
    }


    static var allTests : [(String, (IconvTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
