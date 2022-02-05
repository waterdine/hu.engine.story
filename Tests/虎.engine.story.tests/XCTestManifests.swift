import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(虎_engine_story_tests.allTests),
    ]
}
#endif
