//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import SwiftParser
import SwiftSyntax

public struct Symbol {
    public let name: String
    public let line: Int
    public let column: Int
    public let definedIn: String
    
    init(name: String, definedIn: String, line: Int, column: Int) {
        self.name = name
        self.definedIn = definedIn
        self.line = line
        self.column = column
    }
    
    func isUsed(allFiles: [String], fileProvider: FileProvider, verbose: Bool) -> Bool {
        if let usage = allFiles.concurrentFirst(where: { filePath in
            if filePath == definedIn {
                return numberOfUsages(in: filePath, fileProvider: fileProvider) > 1
            } else {
                return isUsed(in: filePath, fileProvider: fileProvider)
            }
        }) {
            if verbose {
                print("\(name): Used in \(usage)")
            }
            return true
        } else {
            return false
        }
    }
    
    private func isUsed(in file: String, fileProvider: FileProvider) -> Bool {
        guard let source = fileProvider.getSource(for: file) else {
            return false
        }
        return source.contains(name)
    }
    
    private func numberOfUsages(in file: String, fileProvider: FileProvider) -> Int {
        guard let source = fileProvider.getSource(for: file) else {
            return 0
        }
        return source.components(separatedBy: name).count - 1
    }
    
    func matches(regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex.firstMatch(in: name, options: [], range: range) != nil
    }
    
    static func symbols(from file: String, fileProvider: FileProvider) -> [Symbol] {
        guard let source = fileProvider.getSource(for: file) else {
            return []
        }
        
        // Parse the source file into a syntax tree
        let sourceFile = Parser.parse(source: source)
        
        // Create a visitor to traverse the syntax tree
        class SymbolVisitor: SyntaxVisitor {
            var symbols: [Symbol] = []
            let filePath: String
            let fileContents: String
            
            init(filePath: String, fileContents: String) {
                self.filePath = filePath
                self.fileContents = fileContents
                super.init(viewMode: .sourceAccurate)
            }

            override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
                
                let (line, column) = fileContents.lineAndColumn(at: node.position) ?? (0, 0)
                let symbol = Symbol(
                    name: node.name.text,
                    definedIn: filePath,
                    line: line,
                    column: column
                )
                symbols.append(symbol)
                return .skipChildren
            }
            
            override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
                let (line, column) = fileContents.lineAndColumn(at: node.position) ?? (0, 0)
                let symbol = Symbol(
                    name: node.name.text,
                    definedIn: filePath,
                    line: line,
                    column: column
                )
                symbols.append(symbol)
                return .skipChildren
            }
            
            override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
                let (line, column) = fileContents.lineAndColumn(at: node.position) ?? (0, 0)
                let symbol = Symbol(
                    name: node.name.text,
                    definedIn: filePath,
                    line: line,
                    column: column
                )
                symbols.append(symbol)
                return .skipChildren
            }
            
            override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
                let (line, column) = fileContents.lineAndColumn(at: node.position) ?? (0, 0)
                let symbol = Symbol(
                    name: node.name.text,
                    definedIn: filePath,
                    line: line,
                    column: column
                )
                symbols.append(symbol)
                return .skipChildren
            }
            
            override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
                let (line, column) = fileContents.lineAndColumn(at: node.position) ?? (0, 0)
                let symbol = Symbol(
                    name: node.name.text,
                    definedIn: filePath,
                    line: line,
                    column: column
                )
                symbols.append(symbol)
                return .skipChildren
            }
            
            override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
                for binding in node.bindings {
                    if let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                        let variableName = identifierPattern.identifier.text
                        let (line, column) = fileContents.lineAndColumn(at: node.position) ?? (0, 0)
                        let symbol = Symbol(
                            name: variableName,
                            definedIn: filePath,
                            line: line,
                            column: column
                        )
                        symbols.append(symbol)
                    }
                }
                return .skipChildren
            }
            // Add more overrides if you want to capture other symbols like extensions, typealiases, etc.
        }
        
        let visitor = SymbolVisitor(filePath: file, fileContents: source)
        visitor.walk(sourceFile)
        
        return visitor.symbols
    }
}

extension String {
    func lineAndColumn(at position: AbsolutePosition) -> (line: Int, column: Int)? {
        var line = 1
        var column = 1
        var currentIndex = self.startIndex

        for index in self.indices {
            if currentIndex == self.index(self.startIndex, offsetBy: position.utf8Offset) {
                return (line, column)
            }
            if self[index] == "\n" {
                line += 1
                column = 1
            } else {
                column += 1
            }
            currentIndex = self.index(after: currentIndex)
        }
        return nil
    }
}
