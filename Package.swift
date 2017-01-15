import PackageDescription

let package = Package(
    name: "drewag.me",
    dependencies: [
        .Package(url: "https://github.com/drewag/swift-serve-kitura.git", majorVersion: 2),
        .Package(url: "https://github.com/drewag/command-line-parser.git", majorVersion: 1),
        .Package(url: "https://github.com/Zewo/PostgreSQL.git", majorVersion: 0, minor: 14),
    ]
)
