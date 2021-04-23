import Foundation
import LoggerAPI

struct LicenseMarkdownHolder {
    let markdown: String
    static func load(licenses: [LicenseInfo], options: Options) -> LicenseMarkdownHolder {
        var markdown = "# Acknowledgements\nThis project makes use of the following third party libraries:\n\n"
        licenses.forEach { license in
            markdown += "## \(license.name(withVersion: options.config.addVersionNumbers))\n\n\(license.body)\n\n"
        }
        return LicenseMarkdownHolder(markdown: markdown)
    }

    func write(to markdownPath: URL) {
        do {
            try markdown.data(using: .utf8)!.write(to: markdownPath)
        } catch let e {
            Log.error("Failed to write to (markdownPath: \(markdownPath)).\nerror: \(e)")
        }
    }
}
