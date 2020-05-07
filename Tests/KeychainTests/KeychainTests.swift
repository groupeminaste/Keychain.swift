import XCTest
@testable import Keychain

final class KeychainTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Keychain().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
