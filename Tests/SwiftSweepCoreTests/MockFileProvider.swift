//
//  File.swift
//  
//
//  Created by Michael Gerasymenko on 25.09.24.
//

import Foundation
@testable import SwiftSweepCore

class MockFileProvider: FileProvider {
    private var files: [String: String]

    init(files: [String: String]) {
        self.files = files
    }

    func getSource(for file: String) -> String? {
        return files[file]
    }

    func findFiles(in directories: [String], extension pathExtension: String) -> [String] {
        return files.keys.filter { $0.hasSuffix(".\(pathExtension)") }
    }
}
