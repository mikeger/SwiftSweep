//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import ArgumentParser
import SwiftSweepCore

@main
struct SwiftSweepCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Find unused code")

    @Argument(help: "Paths to process", completion: .directory)
    var paths: [String]

    @Option(name: .long, help: "Ignore regular expression")
    var ignoreRegex: String?
    
    @Flag(help: "Produce verbose output")
    var verbose: Bool = false

    mutating func run() async throws {
        print(try findUnused(
            at: paths,
            ignoreRegex: ignoreRegex,
            verbose: verbose,
            fileProvider: CachedFileProvider()
        ).map(\.name).joined(separator: ", "))
    }
}
