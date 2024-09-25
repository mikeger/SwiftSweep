//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation

public protocol FileProvider {
    func getSource(for file: String) -> String?
    func findFiles(in directories: [String], extension pathExtension: String) -> [String]
}

public class CachedFileProvider: FileProvider {
    let cache = ThreadSafe<[String: String]>([:])

    public init() {}
    
    public func getSource(for file: String) -> String? {
        return cache.atomically { cacheDict in
            if let source = cacheDict[file] {
                return source
            } else {
                let sourceFileURL = URL(fileURLWithPath: file)
                guard let source = try? String(contentsOf: sourceFileURL) else {
                    print("Cannot open \(sourceFileURL)")
                    return nil
                }
                cacheDict[file] = source
                return source
            }
        }
    }
    
    public func findFiles(in directories: [String], extension pathExtension: String) -> [String] {
        var swiftFiles = [String]()
        let fileManager = FileManager.default

        for directory in directories {
            let url = URL(fileURLWithPath: directory)
            if let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) {
                for case let fileURL as URL in enumerator {
                    do {
                        let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                        if fileAttributes.isRegularFile == true && fileURL.pathExtension == pathExtension {
                            swiftFiles.append(fileURL.path)
                        }
                    } catch {
                        print("Error accessing file attributes for \(fileURL.path): \(error)")
                    }
                }
            } else {
                print("Could not access directory: \(directory)")
            }
        }
        return swiftFiles
    }

}
