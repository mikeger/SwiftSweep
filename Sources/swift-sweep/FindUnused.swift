//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import ArgumentParser
import SwiftSweepCore

@main
struct SwiftSweep: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Find unused code")

    @Argument(help: "Paths to process", completion: .directory)
    var paths: [String]

    @Option(name: .long, help: "Ignore regular expression")
    var ignoreRegex: String?
    
    @Flag(help: "Produce verbose output")
    var verbose: Bool = false
    
    @Flag(help: "Xcode warnings output")
    var xcodeWarnings: Bool = false

    mutating func run() async throws {
        let unused = try findUnused(
            at: paths,
            ignoreRegex: ignoreRegex,
            verbose: verbose,
            fileProvider: CachedFileProvider()
        )
        if xcodeWarnings {
            for symbol in unused {
                let filePath = symbol.definedIn
                let line = symbol.line
                let column = symbol.column
                let message = "Unused symbol '\(symbol.name)'"
                print("\(filePath):\(line):\(column): warning: \(message)")
            }
        }
        else {
            print(unused.map(\.name).joined(separator: ", "))
        }
    }
}
