// Generated automatically by Perfect Assistant Application
// Date: 2016-11-19 04:28:15 +0000
import PackageDescription
let package = Package(
    name: "SwiftBlog",
    targets: [],
    dependencies: [
        Package.Dependency.Package(url: "https://github.com/iamjono/JSONConfig.git", majorVersion: 0, minor: 1),
        Package.Dependency.Package(url: "https://github.com/PerfectlySoft/Perfect-Turnstile-PostgreSQL.git", versions: Version(0,0,0)..<Version(0,9223372036854775807,9223372036854775807)),
        Package.Dependency.Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 0),
        Package.Dependency.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
        Package.Dependency.Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 0),
    ]
)
