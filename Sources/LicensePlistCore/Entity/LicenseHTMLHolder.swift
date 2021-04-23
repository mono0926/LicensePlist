import Foundation
import HTMLEntities
import LoggerAPI

struct LicenseHTMLHolder {
    let html: String
    static func load(licenses: [LicenseInfo], options: Options) -> LicenseHTMLHolder {
        var html = """
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8">
                <title>Acknowledgements</title>
            </head>
            <body>
                <h1>Acknowledgements</h1>
                <p>
                    This project makes use of the following third party libraries:
                </p>

        """
        licenses.forEach { license in
            html += """
                    <h2>\(license.name(withVersion: options.config.addVersionNumbers).htmlEscape())</h2>
                    <pre>\(license.body.htmlEscape())</pre>

            """
        }
        html += """
            </body>
        </html>
        """
        return LicenseHTMLHolder(html: html)
    }

    func write(to htmlPath: URL) {
        do {
            try html.data(using: .utf8)!.write(to: htmlPath)
        } catch let e {
            Log.error("Failed to write to (htmlPath: \(htmlPath)).\nerror: \(e)")
        }
    }
}
