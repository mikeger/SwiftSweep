//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation

public func findUnused(
    at paths: [String],
    ignoreRegex: String? = nil,
    verbose: Bool = false,
    fileProvider: FileProvider
) throws -> [Symbol] {
    let swiftFiles = fileProvider.findFiles(in: paths, extension: "swift")
    let xibFiles = fileProvider.findFiles(in: paths, extension: "xib")
    let allFiles = swiftFiles + xibFiles
    
    var ignorePattern: NSRegularExpression? = nil
    
    if let ignoreRegex {
        ignorePattern = try NSRegularExpression(pattern: ignoreRegex, options: [])
    }

    let allUnusedSymbols: [Symbol] = swiftFiles.concurrentMap { path in
        let symbols = Symbol.symbols(from: path, fileProvider: fileProvider).filter {
            !$0.isUsed(allFiles: allFiles, fileProvider: fileProvider, verbose: verbose)
        }
        if let ignorePattern {
            let filteredSymbols = symbols.filter { symbol in
                !symbol.matches(regex: ignorePattern)
            }
            return filteredSymbols
        }
        else {
            return symbols
        }
    }.reduce([], +)
    
    return allUnusedSymbols
}
