import ArgumentParser
import Foundation
import LicensePlistCore
import LoggerAPI
import XcodeEdit

extension LicensePlist {
    /// Parses and modifies specified Xcode project file.
    ///
    /// For specified targets, adds a "Copy Acknowledgements" build phase.
    /// Skips targets that already have "Copy Acknowledgements" phase.
    /// Used by `AddAcknowledgementsCopyScriptCommand`.
    struct AddAcknowledgementsCopyScript: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Modifies Xcode project to fix package reference for plugins")

        @Option(help: "Path to xcodeproj file")
        var xcodeproj: String

        @Option(help: "Targets for which to remove package reference")
        var target: [String] = []

        mutating func run() throws {
            Logger.configure(logLevel: .normalLogLevel, colorCommandLineFlag: nil)
            Log.info("Parsing \(xcodeproj)...")
            let url = URL(fileURLWithPath: xcodeproj)
            let file = try XCProjectFile(xcodeprojURL: url, ignoreReferenceErrors: true)

            for target in file.project.targets.compactMap(\.value) {
                guard self.target.contains(target.name) else {
                    Log.info("Target \(target.name) skipped")
                    continue
                }
                
                guard !target.buildPhases.hasScript(named: Self.scriptName) else {
                    Log.warning("\(target.name) already has \"\(Self.scriptName)\" build phase")
                    continue
                }
                
                Log.info("Processing \(target.name)...")
                
                let script = try file.createShellScript(name: Self.scriptName, shellScript: Self.script)
                let reference = file.addReference(value: script) as Reference<PBXBuildPhase>
                target.insertBuildPhase(reference, at: target.buildPhases.count)
            }

            try file.write(to: url)
        }
        
        private static let scriptName = "Copy Acknowledgements"
        
        private static let script: String = """
echo "Will copy acknowledgements"

ACKNOWLEDGEMENTS_DIR=${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/com.mono0926.LicensePlist.Output
DESTINATION_PATH=${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Settings.bundle/

cp -r ${ACKNOWLEDGEMENTS_DIR}/* ${DESTINATION_PATH}
rm -rf ${ACKNOWLEDGEMENTS_DIR}
"""
    }
}

private extension Collection where Element == Reference<PBXBuildPhase> {
    func hasScript(named name: String) -> Bool {
        return compactMap(\.value)
            .compactMap { $0 as? PBXShellScriptBuildPhase }
            .map(\.name)
            .contains(name)
    }
}
