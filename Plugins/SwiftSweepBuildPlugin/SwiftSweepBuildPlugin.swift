//
//  Created by Mike Gerasymenko <mike@gera.cx>
//

import Foundation
import PackagePlugin

@main
struct SwiftSweepBuildPlugin: BuildToolPlugin {
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

    func createBuildCommands(
        context: PackagePlugin.PluginContext,
        target: any PackagePlugin.Target
    ) async throws -> [PackagePlugin.Command] {
        let outputDir = context.pluginWorkDirectory

        return [.prebuildCommand(
            displayName: "Searching unused symbols",
            executable: try context.tool(named: "swift-sweep").path,
            arguments: [context.package.directory.string, "--xcode-warnings"],
            outputFilesDirectory: outputDir)]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftSweepBuildPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        var argExtractor = ArgumentExtractor(arguments)
        let ignoreRegex = argExtractor.extractOption(named: "ignore-regex")
        
        let tool = try context.tool(named: "swift-sweep")
        var newArguments = [context.xcodeProject.directory.string, "--xcode-warnings"]
        if !ignoreRegex.isEmpty {
            newArguments.append("--ignore-regex")
            newArguments.append(contentsOf: ignoreRegex)
        }
        try run(tool.path.string, arguments: newArguments)
    }
}

#endif

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
