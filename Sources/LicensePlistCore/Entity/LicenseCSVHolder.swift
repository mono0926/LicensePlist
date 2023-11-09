import Foundation
import LoggerAPI

struct LicenseCSVHolder {
    let csv: String
    static func load(licenses: [LicenseInfo], options: Options) -> LicenseCSVHolder {
        var csv = [
            "Component",
            "License",
            options.config.addSources ? "Origin" : nil,
            "Copyright"
        ]
        .compactMap { $0 }
        .joined(separator: .delemiter) + .newLine

        for license in licenses {
            let component = license.name(withVersion: options.config.addVersionNumbers)
            let licenseType = license.licenseType.rawValue
            let copyright = license.copyright.quoted
            if options.config.addSources, let source = license.source {
                csv += [
                    component,
                    licenseType,
                    source,
                    copyright
                ].joined(separator: .delemiter)
            } else {
                csv += [
                    component,
                    licenseType,
                    copyright
                ].joined(separator: .delemiter)
            }
            csv += .newLine
        }
        return LicenseCSVHolder(csv: csv)
    }

    func write(to csvPath: URL) {
        do {
            try csv.data(using: .utf8)!.write(to: csvPath)
        } catch {
            Log.error("Failed to write to (csvPath: \(csvPath)).\nerror: \(error)")
        }
    }
}

extension LicenseInfo {
    fileprivate var copyright: String {
        let copyrightRange = body.range(
            of: #"Copyright \(c\) .*"#,
            options: .regularExpression
        )
        return copyrightRange.map { String(body[$0]) } ?? ""
    }
}

extension String {
    fileprivate static let newLine = "\n"
    fileprivate static let delemiter = ","
    fileprivate var quoted: String {
        "\"" + self + "\""
    }
}
