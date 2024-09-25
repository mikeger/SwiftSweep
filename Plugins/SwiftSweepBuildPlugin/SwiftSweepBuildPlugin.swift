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

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
