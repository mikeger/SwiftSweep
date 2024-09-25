//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import PackagePlugin

@main
struct SwiftSweepPlugin: CommandPlugin {
    private func run(_ executable: String, arguments: [String] = []) throws {
        let executableURL = URL(fileURLWithPath: executable)

        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()

        let gracefulExit = process.terminationReason == .exit && process.terminationStatus == 0
        if !gracefulExit {
            throw "[ERROR] The plugin execution failed: \(process.terminationReason.rawValue) (\(process.terminationStatus))"
        }
    }

    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let tool = try context.tool(named: "swift-sweep")
        var newArguments = [context.package.directory.string, "--xcode-warnings"]
        newArguments.append(contentsOf: arguments)
        try run(tool.path.string, arguments: newArguments)
    }
}

#if canImport(XcodeProjectPlugin)
    import XcodeProjectPlugin

    extension SwiftSweepPlugin: XcodeCommandPlugin {
        func performCommand(context: XcodePluginContext, arguments: [String]) throws {
            let tool = try context.tool(named: "swift-sweep")
            var newArguments = [context.xcodeProject.directory.string, "--xcode-warnings"]
            newArguments.append(contentsOf: arguments)
            try run(tool.path.string, arguments: newArguments)
        }
    }
#endif

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
