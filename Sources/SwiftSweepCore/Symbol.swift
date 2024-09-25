//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import SwiftParser
import SwiftSyntax

public struct Symbol {
    public let name: String
    public let definedIn: String
    
    init(name: String, definedIn: String) {
        self.name = name
        self.definedIn = definedIn
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
            var symbols: [String] = []
            
            override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
                let functionName = node.name.text
                symbols.append(functionName)
                return .skipChildren
            }
            
            override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
                let structName = node.name.text
                symbols.append(structName)
                return .skipChildren
            }
            
            override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
                let className = node.name.text
                symbols.append(className)
                return .skipChildren
            }
            
            override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
                let enumName = node.name.text
                symbols.append(enumName)
                return .skipChildren
            }
            
            override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
                let protocolName = node.name.text
                symbols.append(protocolName)
                return .skipChildren
            }
            
            override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
                for binding in node.bindings {
                    if let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                        let variableName = identifierPattern.identifier.text
                        symbols.append(variableName)
                    }
                }
                return .skipChildren
            }
            
            // Add more overrides if you want to capture other symbols like extensions, typealiases, etc.
        }
        
        let visitor = SymbolVisitor(viewMode: .sourceAccurate)
        visitor.walk(sourceFile)
        
        return visitor.symbols.map { Symbol(name: $0, definedIn: file) }
    }
}
