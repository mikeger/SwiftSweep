//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import XCTest
@testable import SwiftSweepCore

final class SwiftSweepCoreTests: XCTestCase {
    func testIdentifiesUnusedSymbols() throws {
        // Mock file contents
        let files = [
            "/path/to/FileA.swift": """
                class UnusedClass {}
                class UsedClass {}
                """,
            "/path/to/FileB.swift": """
                let instance = UsedClass()
                """
        ]
        
        let fileProvider = MockFileProvider(files: files)
        
        // Paths to analyze
        let paths = ["/path/to"]
        
        // Run the tool
        let unusedSymbols = try findUnused(at: paths, verbose: true, fileProvider: fileProvider)
        
        // Assert that UnusedClass is identified as unused
        XCTAssertEqual(unusedSymbols.count, 2)
        XCTAssertEqual(Set(unusedSymbols.map(\.name)), Set(["UnusedClass", "instance"]))
        
    }
    
    func testIdentifiesUsedSymbols() throws {
        // Mock file contents
        let files = [
            "/path/to/FileA.swift": """
                class UsedClass {}
                """,
            "/path/to/FileB.swift": """
                let instance = UsedClass()
                """
        ]
        
        let fileProvider = MockFileProvider(files: files)
        
        // Paths to analyze
        let paths = ["/path/to"]
        
        // Run the tool
        let unusedSymbols = try findUnused(at: paths, verbose: true, fileProvider: fileProvider)
        
        // Assert that there are no unused symbols
        XCTAssertEqual(unusedSymbols.count, 1)
        XCTAssertEqual(Set(unusedSymbols.map(\.name)), Set(["instance"]))
    }
    
    func testIgnoreRegex() throws {
        // Mock file contents
        let files = [
            "/path/to/FileA.swift": """
                class TestClass {}
                class NormalClass {}
                """,
            "/path/to/FileB.swift": """
                // No usage
                """
        ]
        
        let fileProvider = MockFileProvider(files: files)
        
        // Paths to analyze
        let paths = ["/path/to"]
        let ignoreRegex = "^Test.*"
        
        // Run the tool
        let unusedSymbols = try findUnused(
            at: paths,
            ignoreRegex: ignoreRegex,
            verbose: true,
            fileProvider: fileProvider
        )
        
        // Assert that TestClass is ignored and only NormalClass is reported
        XCTAssertEqual(unusedSymbols.count, 1)
        XCTAssertEqual(unusedSymbols.first?.name, "NormalClass")
    }
}
